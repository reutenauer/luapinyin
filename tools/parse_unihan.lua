-- Extract kMandarin fields from the Unihan database,
-- and make it into a Lua table.
-- Arthur Reutenauer, Paris, 2009-03-16.

function parse_unihan()
  local pinyins = { }
  local char
  local function init_char(hex)
    char = tonumber(hex, 16)
    if char then
      pinyins[char] = { }
    end
  end

  local function add_pinyin(pinyin)
    table.insert(pinyins[char], pinyin)
  end

  local unicode_version = "5.1.0"
  local home = os.getenv("HOME")
  local unihan_path = home .. "/Unicode/" .. unicode_version .. "/Unihan.txt"

  local usv = "U+" * ((lpeg.R"09" + lpeg.R"AF" + lpeg.R"af")^4 / init_char)
  local pinyin = lpeg.R"AZ"^1 * lpeg.R"15" / add_pinyin
  local mand = lpeg.P"kMandarin"
  local tab = lpeg.P"\t"
  local space = lpeg.P" "
  local unihan_field = usv * tab * mand * tab * pinyin
    * (space^1 * pinyin)^0

  for line in io.lines(unihan_path) do
    unihan_field:match(line)
  end

  kpse.set_program_name("luatex")
  local table_lib = kpse.find_file("l-table.lua")

  if table_lib then
    dofile(table_lib)
    pinyins_file = io.open("pinyins.lua", "w")
    pinyins_file:write(table.serialize(pinyins, "pinyins"))
  end
end

parse_unihan()
