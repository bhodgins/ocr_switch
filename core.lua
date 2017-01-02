-- core.lua - OCR switch core
local cqueues = require('cqueues')

local _CORE = {}

function _CORE.new(config_file)
	local self     = { async = cqueues.new() }
	local _plugins = {}

	self.config = require('configurator').new(config_file) {
		plugin  = 'list',
		switch  = 'scalar',
	}

	-- Subsystems:
	-- self.switch = require('switch').new(core)

	function self.load_plugin(plugin_file)
		local plugin_obj = require(plugin_file).new(self)
		table.insert(_plugins, plugin_obj)
		plugin_obj.pre_init() -- Load time (pre) initialization
		print('Loaded plugin: ' .. plugin_file .. '.lua')
	end

	function self.run()
		-- Load plugins:
		for _,plugin_name in ipairs(self.config.data['plugin']) do
			self.load_plugin(plugin_name)
		end

		-- Runtime (post) ininitialization:
		for _,plugin in ipairs(_plugins) do plugin.init() end

		-- Begin loop:
		assert(self.async:loop())
	end

	return self
end

return _CORE
