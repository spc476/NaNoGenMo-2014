
local lpeg = require "lpeg"

local space = lpeg.locale().space
local alpha = lpeg.locale().alpha
local digit = lpeg.locale().digit

local chara = alpha + lpeg.P"'"
local dash  = lpeg.P"-" * #chara + ""
local chard = alpha * dash
            + chara

word = lpeg.C(lpeg.P"\n\n" * lpeg.P"\n"^0) 
     + lpeg.C(lpeg.S[["?!.,;:()_`]])
     + lpeg.C"--"
     + lpeg.C(digit^1)
     + lpeg.C"Mr."
     + lpeg.C"MR."
     + lpeg.C"Mrs."
     + lpeg.C"MRS."
     + lpeg.C"Dr."
     + lpeg.C"DR."
     + lpeg.C"P. S."
     + lpeg.P"P.S."  / "P. S."
     + lpeg.C"T. E."
     + lpeg.P"T.E." / "T. E."
     + lpeg.C"Gen."
     + lpeg.C(lpeg.P"No." * space * digit^1)
     + lpeg.C"N. B."
     + lpeg.P"N.B." / "N. B."
     + lpeg.C"H."
     + lpeg.C"M."     
     + lpeg.C"O."
     + lpeg.C"Z."
     + lpeg.C(chara * chard^0)

words = (lpeg.P(1) - word)^0 * word

local doc   = lpeg.Ct(words^1)

local FILE = arg[1] or io.stdin
local f

if type(FILE) == 'string' then
  f = io.open(FILE)
else
  f = FILE
end

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
