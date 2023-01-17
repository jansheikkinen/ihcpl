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

return {
  panic = panic,
  printf = printf,
  read_file = read_file,
  split_words = split_words,
  split_chars = split_chars,
}