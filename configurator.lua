local _CONFIG = {}
	
function _CONFIG.new(filename)
	return function(params)
		local self = {
			data = {} -- Where configuration data is stored
		}

		-- Setup environment:
		local config_env = {}
		for k, v in pairs(params) do
			if     v == 'scalar' then
				config_env[k] = function(arg) self.data[k] = arg end
			elseif v == 'list' then
				self.data[k]  = {}

				config_env[k] = function(params)
					table.insert(self.data[k], params)
				end
			elseif v == 'hash' then
				self.data[k]  = {}

				config_env[k] = function(key)
					return function(params)
						self.data[k][key] = params
					end
				end
			end
		end

		local chunk = assert(loadfile(filename, 't', config_env))
		chunk()

		return self
	end
end

return _CONFIG
