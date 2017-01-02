-- plugins/tcpconsole.lua - TCP Interface to OCR switch shell(s)
local socket       = require('cqueues.socket')

local plugin_base  = require('plugin')
local configurator = require('configurator')

------------ Login shell class ------------


local shell_base = require 'shell'

local STATE_USER = 1
local STATE_PASS = 2

_LOGIN_SHELL = {}

function trim_iac(s)
	if s:sub(1,1) == "\255" then
		return s:sub(4)
	else
		return s
	end
end

function _LOGIN_SHELL.bless(self, params)
	local handle = params['handle']
	local state  = STATE_USER
	local tmp    = {}

	function self._input(line)
		line = trim_iac(line)

		if state == STATE_USER then
			tmp[STATE_USER] = line
			handle:write("password: \255\251\1")
			handle:flush()
			--handle:write('password: ')
			state = STATE_PASS
		elseif state == STATE_PASS then
			-- TODO: Authenticate

			-- print(tmp[STATE_USER] .. ':' .. line)
			if params['system_config']['data']['console']['username'] == tmp[STATE_USER]
			  and params['system_config']['data']['console']['password'] == line then

				-- Success!
				handle:write("\255\252\1")
				handle:flush()

				local motd_fh = io.open('motd.txt', 'r')
				local motd_data = motd_fh:read('*all')
				motd_fh:close()

				handle:write(motd_data)

				params['console'].enter_shell(params['system_config']['data']['console']['default_shell'])
			else

				-- Incorrect:
				handle:write("\nAuthentication failed.\n\n")
				handle:write("username: \255\252\1")
				handle:flush()
				--handle.write('username: ')
				state = STATE_USER
			end
		end
	end

	handle:write("username: \255\252\1")
	handle:flush()
	-- handle:write('username: ')

	return self
end

function _LOGIN_SHELL.new(params) return _LOGIN_SHELL.bless(shell_base.new(params), params) end


------------ Console class ------------

local _CONSOLE = {}

function _CONSOLE.new(params)
	local self = {}

	local _async = params['async']  ~= nil and params['async']  or error("cqueues required")
	local handle = params['handle'] ~= nil and params['handle'] or error("handle required")

	local function console_in(line)
		self.active_shell._input(line)
	end

	function self.enter_shell(shell)
		shell = require(shell).new {
			last_shell = self.active_shell,
			handle = handle,
			system_config = params['config'],
			console = self
		}

		self.active_shell = shell -- TODO: Error handling
	end

	-- Setup the console login shell:
	local shell = require('shells/login').new {
		last_shell    = '',
		handle        = handle,
		system_config = params['config'],
		console       = self
	}

	self.active_shell = shell

	_async:wrap(function()
		for line in handle:lines() do
			console_in(line)
		end
	end)

	return self
end


------------ Plugin class ------------

local _CONSOLE_PLUGIN = {}

function _CONSOLE_PLUGIN.bless(self, core)
	local config   = {}
	local clients  = {}
	local listener = nil	

	function self.pre_init()
		-- Load configuration file:
		config = configurator.new 'config/tcpconsole.lua' {
			enabled          = 'scalar',
			username         = 'scalar',
			password         = 'scalar',
			bind             = 'scalar',
			port             = 'scalar',
			default_shell    = 'scalar',
		}
	end

	-- Instantiate a console listener, listen for clients:
	function self.init()
		if config.data['enabled'] == true then
			listener = socket.listen(config.data['bind'], config.data['port'])

			-- Create watcher for client connections:
			core.async:wrap(function()
				for client in listener:clients() do
					console_obj = _CONSOLE.new {
						handle  = client,
						async   = core.async,
						config  = config,
					}
					table.insert(clients, console_obj) -- Add client to roster
				end
			end)

			print("The management console will be accessible via " ..
				config.data['bind'] .. ':' .. config.data['port'])
		end
	end

	return self
end

-- Semi-Inheritance of plugin base class:
function _CONSOLE_PLUGIN.new(core)
	return _CONSOLE_PLUGIN.bless(plugin_base.new(), core)
end

return _CONSOLE_PLUGIN
