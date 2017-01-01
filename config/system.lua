--[[ main system configuration file
These config files are real Lua scripts, and are executed as Lua. Be sure
to make use of the power of Lua in your config files when you can!
--]]

-- A management console (optional) is highly recommended and allows you to
-- alter the configuration of the switch from telnet, netcat, etc:
console {
	enabled  = true,
	username      = 'admin',
	password      = 'admin',
	bind          = '127.0.0.1',
	port          = 9002,
	default_shell = 'shells/config', -- Default shell to enter

	-- Additional shells should be listed here:
	shells        = {
		-- 'shells/gert',
		-- 'shells/ocrnnr',
	}
}

-- This is where all of the main OCR switching requests will go through.
-- port 9001 is default:
switch {
	bind          = '127.0.0.1',
	port          = 9001
}
