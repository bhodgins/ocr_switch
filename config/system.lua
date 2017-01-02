--[[ main system configuration file
These config files are real Lua scripts, and are executed as Lua. Be sure
to make use of the power of Lua in your config files when you can!
--]]

-- This is where all of the main OCR switching requests will go through.
-- port 9001 is default:
switch {
	bind          = '127.0.0.1',
	port          = 9001
}

-- User defined plugins can be specified here:
plugin 'plugins/tcpconsole'
-- plugin 'plugins/example'
