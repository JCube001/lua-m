--[[
The MIT License (MIT)

Copyright (c) 2016 Jacob McGladdery

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

-- Cache global built-in functions
local ceil   = math.ceil
local floor  = math.floor
local insert = table.insert
local ipairs = ipairs
local max    = math.max
local min    = math.min
local pairs  = pairs
local pow    = math.pow
local remove = table.remove
local sort   = table.sort
local sqrt   = math.sqrt

-- Cache global built-in variables
local huge = math.huge

-- The module
local m ={}
m.VERSION = "0.1.0"

-- Functions

function m.isEven(value)
    return value % 2 == 0
end

function m.isOdd(value)
    return value % 2 == 1
end

function m.clamp(minimal, maximal, value)
    return max(minimal, min(maximal, value))
end

function m.round(value, digits)
    digits = digits or 0
    local exponent = pow(10, digits)
    return floor((value * exponent) + 0.5) / exponent
end

function m.sum(array)
    local result = 0
    for _, value in ipairs(array) do
        result = result + value
    end
    return result
end

function m.product(array)
    local result = 1
    for _, value in ipairs(array) do
        result = result * value
    end
    return result
end

-- Statistics

m.stat = {}

function m.stat.mean(array)
    return m.sum(array) / #array
end

function m.stat.median(array, isSorted)
    if not isSorted then
        sort(array)
    end
    local length = #array
    local midpoint = length / 2
    if m.isOdd(length) then
        return array[ceil(midpoint)]
    end
    return (array[midpoint] + array[midpoint + 1]) / 2
end

function m.stat.mode(array)
    local counts = {}
    for _, v in ipairs(array) do
        local value = counts[v]
        if nil == value then
            counts[v] = 1
        else
            counts[v] = value + 1
        end
    end
    local mostFrequent = 0
    for k, v in pairs(counts) do
        if v > mostFrequent then
            mostFrequent = v
        end
    end
    local result = {}
    for k, v in pairs(counts) do
        if v == mostFrequent then
            insert(result, k)
        end
    end
    return result
end

function m.stat.deviation(value, mean)
    return pow(value - mean, 2)
end

function m.stat.variance(array)
    local sum = 0
    local mean = m.stat.mean(array)
    for _, value in ipairs(array) do
        sum = sum + m.stat.deviation(value, mean)
    end
    return (1 / #array) * sum
end

function m.stat.standardDeviation(array)
    return sqrt(m.stat.variance(array))
end

function m.stat.minMax(array)
    local maximal = -huge
    local minimal = huge
    for _, value in ipairs(array) do
        maximal = max(maximal, value)
        minimal = min(minimal, value)
    end
    return minimal, maximal
end

-- Moving Averages

m.stat.average = {}

function m.stat.average.simple(window)
    local interval = {}
    return function(value)
        if #interval == window then
            remove(interval, 1)
        end
        insert(interval, value)
        return m.stat.mean(interval)
    end
end

function m.stat.average.cumulative()
    local previous = 0
    local n = 1
    return function(value)
        local result = (value + ((n - 1) * previous)) / n
        previous = result
        n = n + 1
        return result
    end
end

-- Return the module
return m
