
local lpeg = require "lpeg"

local space = lpeg.locale().space
local alpha = lpeg.locale().alpha
local word

if false then
  word  = space^0
        * lpeg.C((lpeg.P(1) - space)^1)
else
  word = (lpeg.P(1) - alpha)^0
       * (
           lpeg.C(lpeg.P"Mr.") + lpeg.C((alpha + lpeg.P"'")^1)
         )
end

local doc   = lpeg.Ct(word^1)

local FILE = arg[1] or "/home/spc/LINUS/blackbox/writings/docs/neuromancer.txt"

local f = io.open(FILE)
local d = f:read("*a")
f:close()

local words = doc:match(d)
local uniq  = {}
for i = 1 , #words do
  if not uniq[words[i]] then
    uniq[words[i]] = 1
  else
    uniq[words[i]] = uniq[words[i]] + 1
  end
end

local list = {}
for word,count in pairs(uniq) do
  table.insert(list,{ word = word , count = count })
end

table.sort(list,function(a,b)
  return a.count > b.count
end)

for i = 1 , #list do
  print(list[i].count,list[i].word)
end

--show = require "org.conman.table".show
--show(uniq)
