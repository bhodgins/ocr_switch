-- vpath.lua - VPI handling

local _VPATH = {}

function _VPATH.new()
	local self = { ready = 0 }

	-- Our VCI handlers are stored here
	local VCI = {}

	local function _input(data)

	end

	-- Send data through VCI, via VPI
	function self.put(vci, data)
		VCI[vci].put(data)
	end

	-- Read data from VPI, through VCI
	function self.get(vci, data)
		cooked_data = VCI[vci].get(data)

		-- TODO: Handle data from here
	end

	return self
end

return _VPATH
