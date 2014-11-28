#!/usr/bin/env lua

require "org.conman.math".randomseed()

-- Markov Chain Program in Lua

function allwords ()
  local line = io.read()    -- current line
  local pos = 1             -- current position in the line
  return function ()        -- iterator function
    while line do           -- repeat while there are lines
      local s, e = string.find(line, "%w+", pos)
      if s then      -- found a word?
        pos = e + 1  -- update next position
        return string.sub(line, s, e)   -- return the word
      else
        line = io.read()    -- word not found; try next line
        pos = 1             -- restart from first position
      end
    end
    return nil            -- no more lines: end of traversal
  end
end

local statetab

function insert (index, value)
  if not statetab[index] then
    statetab[index] = {}
  end
  table.insert(statetab[index], value)
end

local N      = 3
local MAXGEN = 50000
local NOWORD = "\n"

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
