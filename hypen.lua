
local lpeg = require "lpeg"

local alpha = lpeg.locale().alpha
local space = lpeg.locale().space

local hyphword = lpeg.C(alpha^1) * lpeg.P"-\n" * space^1 * lpeg.C(alpha^1)
               / function(left,right)
                   return left .. "-" .. right
                 end

local doc = lpeg.Ct(((lpeg.P(1) - hyphword)^1 + hyphword)^1)

local f = io.open("/home/spc/LINUS/blackbox/writings/docs/neuromancer.txt")
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

