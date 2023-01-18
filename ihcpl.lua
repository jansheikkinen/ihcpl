#!/bin/lua

-- ihcpl.lua
-- a interpreted homoiconic concatenative programming language

local interpreter = require("interpreter")

local function main()
  interpreter.interpret(arg[1])
end

return main()
