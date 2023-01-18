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

-- ## INTERPRETER ## --
local LEVEL = 0
local function interpret(file)
  LEVEL = LEVEL + 1

  local program = u.read_file(file)
  local chars = u.split_chars(program)
  table.insert(chars, " ")
  for _, c in ipairs(chars) do vm:step(c) end

  LEVEL = LEVEL - 1
end

local function init_repl() end

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

  -- u.printf("%d | %6s -> %6s %2s | %16s | ", LEVEL, state, self.state.current, char,
  --   table.concat(self.state.saved_chars))
  -- for _, v in ipairs(self.stack) do
  --   u.printf("%s ", v)
  -- end
  -- u.printf("\n")
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

      if type(action) == "function" then
        action(vm)
      elseif type(action) == "string" then
        vm:push(action)
        vm.defined_words["eval"](vm)
      else
        u.panic(4, string.format("invalid word definition %s", word))
      end
    end
  end

  if not did_match then
    u.panic(1, "no words have been defined with that name!\n")
  end
end

function vm:try_push_num(char)
  local word = self:pop_word(char)

  if tonumber(word) ~= nil then
    self:push(tonumber(word))
  else
    -- theoretically unreachable(?)
    u.panic(2, "not a valid number!\n")
  end
end

function vm:try_push_str(char)
  local word = self:pop_word(char)

  if char == "'" then
    if word == u.SPACE or word == u.NEWLINE or word == u.TAB or #word == 1 then
      self:push(word)
    else
      u.panic(3, "not a valid character!\n")
    end
  end

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

-- Homoiconicity
vm.defined_words["eval"] = function(self)
  local a = self:pop()
  interpret(a)
end

vm.defined_words["alias"] = function(self)
  self.defined_words[self:pop()] = self:pop()
end

-- ### Stack Manipulation Operations ### --
vm.defined_words["drop"] = function(self)
  self:pop()
end

vm.defined_words["dup"] = function(self)
  local a = self:pop()
  self:push(a)
  self:push(a)
end

vm.defined_words["swap"] = function(self)
  local a = self:pop()
  local b = self:pop()

  self:push(a)
  self:push(b)
end

vm.defined_words["rot>"] = function(self)
  local a = self:pop()
  local b = self:pop()
  local c = self:pop()

  self:push(a)
  self:push(c)
  self:push(b)
end

vm.defined_words["rot<"] = function(self)
  local a = self:pop()
  local b = self:pop()
  local c = self:pop()

  self:push(b)
  self:push(a)
  self:push(c)
end

vm.defined_words["over"] = function(self)
  local a = self:pop()
  local b = self:pop()

  self:push(b)
  self:push(a)
  self:push(b)
end

-- ### Arithmetic Operations ### --
vm.defined_words["+"] = function(self)
  self:push(self:pop() + self:pop())
end

vm.defined_words["-"] = function(self)
  self:push(self:pop() - self:pop())
end

vm.defined_words["*"] = function(self)
  self:push(self:pop() * self:pop())
end

vm.defined_words["/"] = function(self)
  self:push(self:pop() / self:pop())
end

vm.defined_words["%"] = function(self)
  self:push(self:pop() % self:pop())
end

-- ### Control Flow Operations  ### --
-- Beware of short-circuiting when popping

vm.defined_words["or"] = function(self)
  local a = u.to_lbool(self:pop())
  local b = u.to_lbool(self:pop())
  self:push(u.to_ibool(a or b))
end

vm.defined_words["and"] = function(self)
  local a = u.to_lbool(self:pop())
  local b = u.to_lbool(self:pop())
  self:push(u.to_ibool(a and b))
end

vm.defined_words["not"] = function(self)
  self:push(u.to_ibool(not u.to_lbool(self:pop())))
end

-- ### Comparison Operations ### --
vm.defined_words["="] = function(self)
  self:push((self:pop() == self:pop()) and 1 or 0)
end

vm.defined_words["!="] = "= not"

vm.defined_words["<"] = function(self)
  self:push((self:pop() < self:pop()) and 1 or 0)
end

vm.defined_words["<="] = "over over < rot> = or"

vm.defined_words[">"] = function(self)
  self:push((self:pop() > self:pop()) and 1 or 0)
end

vm.defined_words[">="] = "over over > rot> = or"

-- ### Miscellaneous Operations ### --
vm.defined_words["."] = function(self)
  print(self:pop())
end

return {
  interpret = interpret,
  init_repl = init_repl,
}
