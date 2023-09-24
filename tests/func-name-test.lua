local time = require "time"
DEFAULT_REPEATS = 100

local function myfunc()
	local x = 1
end

function foo()
	local x = 1
end

local function out()
	local x = 1
	local function inner()
		local x = 1
	end
	return inner
end

time(myfunc)
time(foo)
time(out)
time(out())
