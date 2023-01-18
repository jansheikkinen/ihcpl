-- interpreter.lua

local u = require("util")

local BEGIN, INWORD, INNUM, INSTR = "BEGIN", "INWORD", "INNUM", "INSTR"
local vm = {
  stack = { },
  defined_words = { },
  state = {
    current = BEGIN,
    saved_chars = { },
    transitions = { },
  },
}

-- ## VM STACK ## --
function vm:push(elem)
  table.insert(self.stack, elem)
end

function vm:pop()
  return table.remove(self.stack)
end

-- ## VM STATE MACHINE ## --
function vm:step(char)
  local trans = self.state.transitions
  local state = self.state.current
  local ctype = 4
  if tonumber(char) ~= nil then
    ctype = 1
  elseif char == "." and state == INNUM then
    ctype = 1
  elseif char == "\"" or char == "\'" then
    ctype = 2
  elseif char == u.SPACE or char == u.NEWLINE
    or char == u.TAB or char == u.EOF then
    ctype = 3
  end

  self.state.current = trans[state][ctype][1]
  local f = trans[state][ctype][2] or function(_, _) end
  f(self, char)

  -- u.printf("%6s -> %6s %2s | %s\n", state, self.state.current, char,
  --   table.concat(self.state.saved_chars))
end

function vm:save_char(char) table.insert(self.state.saved_chars, char) end

function vm:pop_word(char)
  if not u.is_whitespace(char) and char ~= "\"" and char ~= "'" then
    table.insert(self.state.saved_chars, char)
  end

  local word = table.concat(self.state.saved_chars)
  self.state.saved_chars = { }
  return word
end

function vm:try_exec_word(char)
  local word = self:pop_word(char)

  local did_match = false
  for dword, action in pairs(self.defined_words) do
    if dword == word then
      did_match = true
      action(vm)
    end
  end

  if not did_match then
    u.panic(1, "no words have been defined with that name!")
  end
end

function vm:try_push_num(char)
  local word = self:pop_word(char)

  if tonumber(word) ~= nil then
    self:push(tonumber(word))
  else
    -- theoretically unreachable(?)
    u.panic(2, "not a valid number!")
  end
end

function vm:try_push_str(char)
  local word = self:pop_word(char)

  -- TODO: str vs char validation
  -- TODO: remove "" and ''
  self:push(word)
end

--[
-- e: execute word
-- p: push value if valid
--
-- ###### | number | dquote  | whitespace | other  |
-- -------+--------+---------+------------+--------+
-- begin  | innum  | instr   | begin      | inword |
-- inword | inword | inword  | begin/e    | inword |
-- innum  | innum  | inword  | begin/p    | inword |
-- instr  | instr  | begin/p | instr      | instr  |
--
--]

vm.state.transitions = {
  BEGIN = {
    { INNUM,  vm.save_char },
    { INSTR,  nil }, -- don't save quotations
    { BEGIN,  nil },
    { INWORD, vm.save_char },
  },
  INWORD = {
    { INWORD, vm.save_char },
    { INWORD, vm.save_char },
    { BEGIN,  vm.try_exec_word },
    { INWORD, vm.save_char },
  },
  INNUM = {
    { INNUM,  vm.save_char },
    { INWORD, vm.save_char },
    { BEGIN,  vm.try_push_num  },
    { INWORD, vm.save_char },
  },
  INSTR = {
    { INSTR, vm.save_char },
    { BEGIN, vm.try_push_str },
    { INSTR, vm.save_char },
    { INSTR, vm.save_char },
  },
}

-- ## VM WORD DEFINITIONS ## --
vm.defined_words["+"] = function(self)
  local a = self:pop()
  local b = self:pop()
  self:push(a + b)
end

vm.defined_words["."] = function(self)
  print(self:pop())
end

-- ## INTERPRETER ## --
local function interpret(file)
  local program = file
  local chars = u.split_chars(program)
  table.insert(chars, " ")
  for _, c in ipairs(chars) do vm:step(c) end
end

local function init_repl() end

return {
  interpret = interpret,
  init_repl = init_repl,
}
