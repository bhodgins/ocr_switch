-- console.lua - Management console object

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

return _CONSOLE
