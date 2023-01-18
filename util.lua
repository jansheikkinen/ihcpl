-- util.lua

-- c-like printf
local function printf(fmt, ...)
  io.write(string.format(fmt, ...))
end

-- print error msg and exit with err code
local function panic(err, msg)
  printf("[error]: %s", msg)
  os.exit(err)
end

-- read file to string
local function read_file(file)
  local f = io.open(file, "r")
  if not f then return "" end

  local str = f:read("*a")
  f:close()
  return str
end

-- split a string into a table of tokens by whitespace
local function split_words(str)
  local t = { }
  for s in str:gmatch("([^%s]+)") do
    table.insert(t, s)
  end

  return t
end

-- split a string into a table of characters
local function split_chars(str)
  local t = { }
  for s in str:gmatch(".") do
    table.insert(t, s)
  end

  return t
end

local function is_whitespace(char)
  return (char == " ") or (char == "\n") or (char == "\t")
end

local function to_lbool(val)
  if val == 0 or val == nil then return false end
  return true
end

local function to_ibool(val)
  return val and 1 or 0
end

return {
  SPACE = " ",
  NEWLINE = "\n",
  TAB = "\t",
  EOF = -1,
  panic = panic,
  printf = printf,
  read_file = read_file,
  split_words = split_words,
  split_chars = split_chars,
  is_whitespace = is_whitespace,
  to_lbool = to_lbool,
  to_ibool = to_ibool,
}
