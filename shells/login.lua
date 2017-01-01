-- shells/login.lua - Login shell (default default shell)
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

return _LOGIN_SHELL
