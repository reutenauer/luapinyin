-- Extract kMandarin fields from the Unihan database,
-- and make it into a Lua table.
-- Arthur Reutenauer, Paris, 2009-03-16.

function parse_unihan()
  local pinyins = { }
  local char
  -- Function by Wolfgang Schuster.
  -- See http://www.ntg.nl/pipermail/ntg-context/2009/039043.html
  local function add_accent(str)
    str = string.gsub(str,"r1","1r")
    str = string.gsub(str,"r2","2r")
    str = string.gsub(str,"r3","3r")
    str = string.gsub(str,"r4","4r")
    str = string.gsub(str,"r5","5r")
    str = string.gsub(str,"ng1","1ng")
    str = string.gsub(str,"ng2","2ng")
    str = string.gsub(str,"ng3","3ng")
    str = string.gsub(str,"ng4","4ng")
    str = string.gsub(str,"ng5","5ng")
    str = string.gsub(str,"n1","1n")
    str = string.gsub(str,"n2","2n")
    str = string.gsub(str,"n3","3n")
    str = string.gsub(str,"n4","4n")
    str = string.gsub(str,"n1","5n")
    str = string.gsub(str,"ai1","a1i")
    str = string.gsub(str,"ai2","a2i")
    str = string.gsub(str,"ai3","a3i")
    str = string.gsub(str,"ai4","a4i")
    str = string.gsub(str,"ai5","a5i")
    str = string.gsub(str,"ei1","e1i")
    str = string.gsub(str,"ei2","e2i")
    str = string.gsub(str,"ei3","e3i")
    str = string.gsub(str,"ei4","e4i")
    str = string.gsub(str,"ei5","e5i")
    str = string.gsub(str,"ao1","a1o")
    str = string.gsub(str,"ao2","a2o")
    str = string.gsub(str,"ao3","a3o")
    str = string.gsub(str,"ao4","a4o")
    str = string.gsub(str,"ao5","a5o")
    str = string.gsub(str,"ou1","o1u")
    str = string.gsub(str,"ou2","o2u")
    str = string.gsub(str,"ou3","o3u")
    str = string.gsub(str,"ou4","o4u")
    str = string.gsub(str,"ou5","o5u")
    str = string.gsub(str,"uu1","v1")
    str = string.gsub(str,"uu2","v2")
    str = string.gsub(str,"uu3","v3")
    str = string.gsub(str,"uu4","v4")
    str = string.gsub(str,"uu","ü") -- is this correct?
    str = string.gsub(str,"o1","ō")
    str = string.gsub(str,"o2","ó")
    str = string.gsub(str,"o3","ǒ")
    str = string.gsub(str,"o4","ò")
    str = string.gsub(str,"e1","ē")
    str = string.gsub(str,"e2","é")
    str = string.gsub(str,"e3","ě")
    str = string.gsub(str,"e4","è")
    str = string.gsub(str,"i1","ī")
    str = string.gsub(str,"i2","í")
    str = string.gsub(str,"i3","ǐ")
    str = string.gsub(str,"i4","ì")
    str = string.gsub(str,"u1","ū")
    str = string.gsub(str,"u2","ú")
    str = string.gsub(str,"u3","ǔ")
    str = string.gsub(str,"u4","ù")
    str = string.gsub(str,"v1","ǖ")
    str = string.gsub(str,"v2","ǘ")
    str = string.gsub(str,"v3","ǚ")
    str = string.gsub(str,"v4","ǜ")
    str = string.gsub(str,"a1","ā")
    str = string.gsub(str,"a2","á")
    str = string.gsub(str,"a3","ǎ")
    str = string.gsub(str,"a4","à")
    return str
  end

  local function init_char(hex)
    char = tonumber(hex, 16)
    if char then
      pinyins[char] = { }
    end
  end

  local function add_pinyin(pinyin)
    pinyin = pinyin:lower()
    pinyin = add_accent(pinyin)
    table.insert(pinyins[char], pinyin)
  end

  local unicode_version = "5.1.0"
  local home = os.getenv("HOME")
  local unihan_path = home .. "/Unicode/" .. unicode_version .. "/Unihan.txt"
  local unihan = io.open(unihan_path, "r")
  if not unihan then
    print("Error: Unihan database not found.")
    print("Download it from ftp://ftp.unicode.org/Public/UNIDATA/Unihan.zip")
    print("and edit the unihan_path variable accordingly.")
    return
  end
  io.close(unihan)

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
    print("Writing output to pinyins.lua")
    pinyins_file:write(table.serialize(pinyins, "pinyins"))
  else
    print("Error: l-table.lua not found, no output written.")
  end
end

parse_unihan()
