#!/bin/lua

-- ihcpl.lua
-- a interpreted homoiconic concatenative programming language

local interpreter = require("interpreter")

local function main()
  interpreter.interpret("420 0.69 + .")
end

return main()
