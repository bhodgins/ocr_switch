-- plugins/example.lua - Example plugin
local plugin_base = require('plugin')

local _EXAMPLE_PLUGIN = {}

function _EXAMPLE_PLUGIN.bless(self, core)

	function self.pre_init()
		print("Hello from Example plugin!")
	end

	return self
end

-- Semi-Inheritance of plugin base class:
function _EXAMPLE_PLUGIN.new(core)
	return _EXAMPLE_PLUGIN.bless(plugin_base.new(), core)
end

return _EXAMPLE_PLUGIN
