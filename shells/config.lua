-- shells/config.lua - Config shell
local shell_base = require 'shell'
local PROMPT = 'config% '

_CONFIG_SHELL = {}

function trim_iac(s)
	if   s:sub(1,1) == "\255" then return s:sub(4)
	else return s end
end

function _CONFIG_SHELL.bless(self, params)
	local handle = params['handle']

	handle:write("\n" .. PROMPT)

	function self._input(line)
		line = trim_iac(line)

		print(line)
		handle:write(PROMPT)
	end

	return self
end

function _CONFIG_SHELL.new(params) return _CONFIG_SHELL.bless(shell_base.new(params), params) end

return _CONFIG_SHELL
