#!/bin/lua

-- ihcpl.lua
-- an interpreted homoiconic concatenative programming language

local interpreter = require("interpreter")

local function main()
  if #arg == 0 then
    interpreter.init_repl()
  else
    interpreter.interpret_file(arg[1])
  end
end

return main()
