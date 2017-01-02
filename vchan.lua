-- vchan.lua - VCI handling
_G['VCHAN_LINK_TYPE_SERVICE'] = 0
_G['VCHAN_LINK_TYPE_FORWARD'] = 1

local _VCHAN = {}

function _VCHAN.new()
	local self = {
		link_type = nil,
	}

	return self
end

return _VCHAN
