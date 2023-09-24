------------------------------ Metadata ------------------------------
local timekeeper = {
	_VERSION     = "timekeeper v1.0.0",
	_DESCRIPTION = "Simple & lightweight function timing (performance) Lua lib.",
	_URL         = "https://github.com/ActivexDiamond/timekeeper",
	_LICENSE     = [[
MIT LICENSE

Copyright (c) 2011 Enrique García Cota

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]
}

------------------------------ Helpers / Internals ------------------------------
function timekeeper:_readLine(n)
	local i = 0
	local source_file = debug.getinfo(4, 'S').source
	for line in io.lines(source_file:sub(2, -1)) do
		i = i + 1
		if i == n then
			return line
		end
	end
	return nil -- line not found
end
function timekeeper:_cursedGetName(f)
	local l = debug.getinfo(f, 'S').linedefined
	local lineStr = self:_readLine(l) or "unknown"
	--Extra parenthesis needed to drop second return val of gsub for cleanliness.
	return (lineStr:gsub("local", ""):gsub("=", ""):gsub("function", ""):
			gsub("%(*%)", ""):gsub(" ", ""):gsub("\t", ""))
end

function timekeeper:_rpad(str, len, char)
	char = char or " "
	str = tostring(str)
	return str .. string.rep(char, len - #str)
end
function timekeeper:_lpad(str, len, char)
	char = char or " "
	str = tostring(str)
	return string.rep(char, len - #str) .. str
end

local optErr = "\nThis error is related to one of the args/opts passed to `time`." ..
"Which might either be because you passed an invalid opt;" ..
"or if you did not pass the one mentioned above; then you might have invalidated that opt either" ..
"in this instance of timekeeper, or in the main defaults."

function timekeeper:_cleanTimeArgs(fOrOpts)
	---Assert main arg.
	local argType = type(fOrOpts)
	assert(argType == 'table' or argType == 'function', "The first arg must be either a function (to time), or a table of options.")

	---Clean args.
	local opts = fOrOpts == 'table' and fOrOpts or {f = fOrOpts}
	local f = opts.f
	opts.getTime 	= opts.getTime 	or self.getTime or self.DEFAULT_GET_TIME
	opts.repeats 	= opts.repeats 	or self.repeats or self.DEFAULT_REPEATS
	opts.cycles 	= opts.cycles 	or self.cycles 	or self.DEFAULT_CYCLES
	opts.pad 		= opts.pad 		or self.pad 	or self.DEFAULT_PAD

	---Assert args.
	if argType == 'table' then
		assert(type(f) 				== 'function', 							"Must either provide f directly, or as `opts.f`." .. optErr)
		assert(type(opts.getTime) 	== 'function', 							"`opts.getTime` must either be `nil`, or a function." .. optErr)
		assert(type(opts.repeats) 	== 'number' 	and opts.repeats > 0, 	"`opts.repeats` must either be `nil`, or a positive number." .. optErr)
		assert(type(opts.cycles) 	== 'number' 	and opts.cycles > 0, 	"`opts.cycles` must either be `nil`, or a positive number." .. optErr)
		assert(type(opts.pad) 		== 'number' 	and opts.pad > 0, 		"`opts.pad` must either be `nil`, or a positive number." .. optErr)
	end

	---Assert name arg.
	local name;
	if opts.name then
		name = type(opts.name) == 'function' and opts.name() or opts.name
	else
		local useCursedGetName;
		--Expicit nil check, as nil should default. But false should not.
		--Can't use ternary, as false should be returned.
		--Basically check for existence in the following proiority: opts, self(inst), self(DEFAULT) and use the first found one.
		if     opts.useCursedGetName ~= nil then     useCursedGetName = opts.useCursedGetName
		elseif self.useCursedGetName ~= nil then     useCursedGetName = self.useCursedGetName
		else                                         useCursedGetName = self.DEFAULT_USE_CURSED_GET_NAME end

		name = useCursedGetName and self:_cursedGetName(f) or debug.getinfo(f, 'n').name
		name = (type(name) == 'string' and #name > 0) and name or "<nameless>"
	end
	name = self:_pad(name, opts.pad)
	
end

------------------------------ Constants ------------------------------
timekeeper.DEFAULT_REPEATS = 2e6
timekeeper.DEFAULT_CYCLES = 5
timekeeper.DEFAULT_PAD = 10
timekeeper.DEFAULT_GET_TIME = os.clock
timekeeper.DEFAULT_USE_CURSED_GET_NAME = false

------------------------------ Core API ------------------------------

---Takes either a function to time, or a table of opts (containing at least an `f` field for the func to time.)
---Every else is just passed into f itself.
function timekeeper:time(fOrOpts, ...)--, b, c, d, e, f
	---Assert and clean args.
	local f, opts = self:_cleanTimeArgs(fOrOpts) 				--Keep f seperate, so that the timing section doesn't waste time indexing a table.

	---Do the actual work.
	local pre = getTime()
	for _ = 1, repeats do
		f(...)--, b, c, d, e, f)
	end
	local total = self:_lpad(getTime() - pre, pad)
	print(name, total .. "s")
end

function timekeeper:new(...)
	assert(#{...} == 0, "`timekeeper:new` got some args, expected none. Did you mean to call `time`?")
	local t = {class = self, __index = self, __call = self.__call}
	return setmetatable(t, t)
end

------------------------------ Metatable / Dispatcher  ------------------------------
function timekeeper.__call(self, ...)
	local count = #{...}
	return count == 0 and timekeeper:new() or timekeeper:time(...)
end

function timekeeper.__index(t, k) 
	error("Trying to read invalid field (" .. tostring(k) .. ") of timekeeper or child. Did you make a typo?")
end

return setmetatable(timekeeper, timekeeper)
