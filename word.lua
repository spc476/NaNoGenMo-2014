-- ***************************************************************
--
-- Copyright 2014 by Sean Conner.  All Rights Reserved.
-- 
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or (at your
-- option) any later version.
-- 
-- This library is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
-- License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with this library; if not, see <http://www.gnu.org/licenses/>.
--
-- Comments, questions and criticisms can be sent to: sean@conman.org
--
-- ====================================================================
--
-- This program was used to determine what, exactly, a "word" would be
-- defined as for use in the Markov chaining process.  The final definition
-- is:
--
--	end of paragraph
--	punctuation
--	numbers
--	letters, optionally with a leading apostrophe ('Tis), an embedded
--		apostrophe (I'll), or a trailing apostrophe (goin'), and
--		futhre-more optional embedded hyphens ('jack-boot').
-- 	A few abbreviations, some of which are normalized to a consistent
--		spelling.
-- 
-- ********************************************************************

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
