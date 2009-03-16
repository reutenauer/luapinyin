dofile("../tools/pinyins.lua")

function pinyinize(head, groupcode)
  for n in node.traverse(head) do
    texio.write(node.type(n.id))
    if node.type(n.id) == "glyph" then
      texio.write_nl(" ", n.char)
      texio.write("  ")
      -- local p = table.serialize(pinyins[n.char])
      local py = pinyins[n.char]
      if py then
        texio.write_nl("term and log", table.serialize(py, string.format("pinyins for U+%04X", n.char)))
	local t = py[1]
	local currnode = n
	for l in t:gmatch(".") do
	  local nl = node.new(node.id("glyph"))
	  nl.char = string.byte(l)
	  node.insert_after(head, currnode, nl)
	  currnode = nl
	end
      end
    else
      texio.write_nl(" ")
    end
  end
  return head
end

function toggle_pinyinize()
  callback.register("pre_linebreak_filter", pinyinize)
end
