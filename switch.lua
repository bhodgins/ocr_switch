-- switch.lua - Main switch component
local cqueues = require('cqueues')
local socket  = require('cqueues.socket')

local console = require('console')
local conf    = require('configurator')

local _SW = {}

function _SW.new()
	local self = {}

	local console_clients  = {} -- list
	local _async           = cqueues.new()

	-- Main loop:
	function self.run()
		local config = conf.new 'config/system.lua' {
			console = 'scalar',
			switch  = 'scalar',
		}

		-- Console listener:
		if config['data']['console']['enabled'] == true then
			local console_listener = socket.listen(config['data']['console']['bind'], config['data']['console']['port'])

			_async:wrap(function()
				for client in console_listener:clients() do
					console_obj = console.new {
						handle  = client,
						async   = _async,
						config  = config,
					}
					table.insert(console_clients, console_obj) -- Add client to roster
				end
			end)

			print("The management console will be accessible via " .. config['data']['console']['bind'] .. ':' .. config['data']['console']['port'])
		end

		assert(_async:loop())
	end

	return self
end

return _SW
