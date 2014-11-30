
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
-- This program was used to deterine what marks the end of a sentence.  The
-- concept of a "sentence" isn't used, but it was useful to find examples of
-- words with embedded periods in them like "Dr." or "No.  15" and the like.
--
-- ********************************************************************


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

local FILE = arg[1] or "corpus/01.txt"

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

