local timekeeper = require "timekeeper"

local function arith() 
	local x = math.random(1000)
	local y = x ^ math.random() * 3
	return y / math.random()
end

local function bigTable() 
	local t = {}
	for i = 1e4, 0, -1 do
		t[i] = math.random()
	end
	return t
end

local function stringConcat()
	local str = ""
	for i = 1e3, 0, -1 do
		str = str .. math.random()
	end
	return str
end

timekeeper(arith)
timekeeper(bigTable)
timekeeper(stringConcat)


