#!/bin/lua

-- ihcpl.lua
-- a interpreted homoiconic concatenative programming language

local interpreter = require("interpreter")

local function main()
  interpreter.interpret_file(arg[1])
end

return main()
