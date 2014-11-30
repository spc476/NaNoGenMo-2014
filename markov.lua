#!/usr/bin/env lua
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
-- This is based upon the code found at <http://www.lua.org/pil/10.2.html>
-- but heavily modified.  The original code hard coded a chain length of
-- two, but this parametrizes the length with a default of 3.  You can 
-- also specify a file, or pipe the data into the program.
-- 
-- ********************************************************************

local randomseed = require "org.conman.math".randomseed
local syslog     = require "org.conman.syslog"

-- Markov Chain Program in Lua

local lpeg = require "lpeg"

local space = lpeg.locale().space
local alpha = lpeg.locale().alpha
local digit = lpeg.locale().digit

local chara = alpha + lpeg.P"'"
local dash  = lpeg.P"-" * #chara + ""
local chard = alpha * dash
            + chara
local word  = lpeg.C(lpeg.P"\n\n") * lpeg.P"\n"^0
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
local words = (lpeg.P(1) - word)^0 * word
local doc   = lpeg.Ct(words^1)

function allwords ()
  local f
  
  if arg[1] then
    f = io.open(arg[1])
  else
    f = io.stdin
  end
  
  local list = doc:match(f:read("*a"))
  f:close()
  
  syslog('debug',"read in words: %d words",#list)
  
  local idx = 1
  return function()
    if idx > #list then
      list = nil
      return nil
    end
    
    local item = list[idx]
    idx = idx + 1
    return item
  end
end

local statetab

function insert (index, value)
  if not statetab[index] then
    statetab[index] = {}
  end
  table.insert(statetab[index], value)
end

local SEED   = randomseed()
local N      = 3
local MAXGEN = 70000
local NOWORD = "\n"

syslog('debug',"SEED=%d",SEED)

-- build table
statetab = {}

local ww = {}
for i = 1 , N do
  table.insert(ww,NOWORD)
end

for w in allwords() do
  insert(table.concat(ww,' '),w)
  table.remove(ww,1)
  table.insert(ww,w)
end

insert(table.concat(ww,' '),NOWORD)

-- generate text

local ww = {}
for i = 1 , N do
  table.insert(ww,NOWORD)
end

io.write(string.format("[SEED=%d]\n\n",SEED))

for i=1,MAXGEN do
  local list = statetab[table.concat(ww,' ')]
  -- choose a random item from list
  local r = math.random(table.getn(list))
  local nextword = list[r]
  if nextword == NOWORD then return end
  io.write(nextword, " ")
  table.remove(ww,1)
  table.insert(ww,nextword)
end
