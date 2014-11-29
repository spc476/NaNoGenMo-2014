


-- end of sentance seems to be:
--
--	'.' _ _
--	'.\n'
--	'."'
--
-- Other uses indicate abreviations.


local lpeg = require "lpeg"

local alpha = lpeg.locale().alpha
local space = lpeg.locale().space

local wordp = (lpeg.C(alpha^1 * lpeg.P".")
            * lpeg.Cs(  (lpeg.locale().space / "_")^0))
            / function(a,b)
                return a .. b
              end
              

local doc   = lpeg.Ct(((lpeg.P(1) - wordp)^1 + wordp)^1)

local FILE = arg[1] or "/home/spc/LINUS/blackbox/writings/docs/neuromancer.txt"

local f = io.open(FILE)
local d = f:read("*a")
f:close()

words = doc:match(d)

uniq = {}
for i = 1 , #words do
  if not uniq[words[i]] then
    uniq[words[i]] = true
  end
end

list = {}
for word in pairs(uniq) do
  table.insert(list,word)
end

table.sort(list)

show = require "org.conman.table".show
show(list)

