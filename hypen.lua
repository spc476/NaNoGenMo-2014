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
-- This program checks the given file for words that are split across lines,
-- using a dash (or hypen) to mark the break.  Common for printed texts to
-- be split up as such.  This was written to see if I had to worry about
-- such words.
--
-- Turns out no---there are no words broken across lines in the files used
-- for this project.
--
-- ********************************************************************

local lpeg = require "lpeg"

local alpha = lpeg.locale().alpha
local space = lpeg.locale().space

local hyphword = lpeg.C(alpha^1) * lpeg.P"-\n" * space^1 * lpeg.C(alpha^1)
               / function(left,right)
                   return left .. "-" .. right
                 end

local doc = lpeg.Ct(((lpeg.P(1) - hyphword)^1 + hyphword)^1)

local f = io.open(arg[1])
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

