local in_verse = false
local verse_level = nil

function Header(el)
  -- Close verse if needed
  if in_verse and el.level <= verse_level then
    in_verse = false
    verse_level = nil
    return {
      pandoc.RawBlock("latex", "\\end{verse}"),
      el
    }
  end

  -- Open verse if header has class
  if el.classes:includes("verse") then
    verse_level = el.level
    in_verse = true

    -- remove class safely
    local newclasses = {}
    for _, c in ipairs(el.classes) do
      if c ~= "verse" then
        table.insert(newclasses, c)
      end
    end
    el.classes = newclasses

    return {
      el,
      pandoc.RawBlock("latex", "\\begin{verse}")
    }
  end

  return el
end

function Para(el)
  if in_verse then
    local newcontent = {}

    for i, inline in ipairs(el.content) do
      if inline.t == "SoftBreak" then
        table.insert(newcontent, pandoc.LineBreak())
      else
        table.insert(newcontent, inline)
      end
    end

    el.content = newcontent
    return el
  end
end

function Pandoc(doc)
  if in_verse then
    table.insert(doc.blocks, pandoc.RawBlock("latex", "\\end{verse}"))
  end
  return doc
end
