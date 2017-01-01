-- shell.lua - Shell base class for console access

local _SHELL = {}

function _SHELL.new(params)

	local self = {
		last_shell = params['last_shell'] ~= nil and params['last_shell']
	}

	-- STUBS (Ovrload these):
	function self._input() end

	return self
end

return _SHELL
