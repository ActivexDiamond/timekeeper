# Timekeeper
A simple single-file library for timing Lua functions. 

Provides only one main function, a small auxilary one, and fully optional configs.

Fully documented in-source using Sumneko's LuaLS!

## WIP 
README is still very WIP, but the source code is plenty commented and fully documented, so that should hold you over for now!

## Hello World
```lua
local timekeeper = require "timekeeper"

local function foo(t, size)
	for i = 1, size, do t[i] = {} end
end

timekeeper(foo) 	--Will print out the time `foo` took!
```

## Installation
Just copy `timekeeper.lua` wherever you want, then require it from the path you put it in. `timekeeper` does NOT define any globals, but can work just fine if required as a global.

E.g. First, copy `timekeeper.lua` into your source folder, then;
```lua
--[RECOMMENDED] In every Lua file that uses timekeeper.
local timekeeper = require "timekeeper"
```
**OR**
```lua
--In a single Lua file, that is executed before any code that uses `timekeeper`.
timekeeper = require "timekeeper"
```

## Auto-Completion
`timekeeper` is fully documented using Sumneko's LuaLS annotations, so as long as you use any IDE which supports LSPs (language server protocols) (E.g. Visual Studio, Neovim, etc...) you should automatically get autocompletion! 

Troubleshooting auto-completion:
1.Make sure that `timekeeper`s path is somewhere that LuaLS can see
1.1. Somewhere inside your source folder.
1.2. Not excluded by your LuaLS config.
2. Make sure LuaLS sees your source folder as a "workspace" (you have a `.git`, `.luarc.json`, and/or other in your source folder). For more info on this see (here)[https://luals.github.io/wiki/configuration/].

## Public API
### Timing
timekeeper(f[, ...])
timekeeper(opts[, ...])

Both are aliases for `timekeeper.time`
### Instancing
timekeeper()

Alias for `timekeeper.new`
### Config / Opts

## Private API
Internally, `timekeeper` uses a bunch of small helper functions to get stuff done (mainly to keep the main `time` function from getting too long and unreadable). These have no real use outside of the `timekeeper` module itself, but are still put inside it in case someone finds a use for them. Those are all prefixed with `_` (single underscore).


## License
`timekeeper` is distributed under the MIT license.

