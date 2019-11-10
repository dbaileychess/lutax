-- This is an example script for using this tax-preparation tool.

-- require the "forms" to be filled out. This will vary from 
-- person-to-person.
local f1040Form = require("2019/f1040")
local w2Form = require("2019/w2")
local scheduleAForm = require("2019/scheduleA")
local scheduleBForm = require("2019/scheduleB")
local f1099divForm = require("2019/f1099-div")
local f1099intForm = require("2019/f1099-int")

-- Load all the user-defined data that is defined in a seaprate file.
local data = require("data")

-- Construct the forms from the user-defined data.
local w2s = {}
for name, w2Data in pairs(data.w2) do
  w2s[#w2s+1] = w2Form.New(name, w2Data)
end

local f1099divs = {}
for name, f1099divData in pairs(data.f1099_div) do
  f1099divs[#f1099divs+1] = f1099divForm.New(name, f1099divData)
end

local f1099ints = {}
for name, f1099intData in pairs(data.f1099_int) do
  f1099ints[#f1099ints+1] = f1099intForm.New(name, f1099intData)
end

local scheduleA = scheduleAForm.New()
scheduleA:AddInputs(data.scheduleA)

local scheduleB = scheduleBForm.New()
scheduleB:AddInputs(data.scheduleB)

local f1040 = f1040Form.New()
f1040:Attach(w2s, f1099divs, f1099ints, scheduleA, scheduleB)
f1040:AddInputs(data.f1040)

-- print out the completed form and all attachments
f1040:PrintOutput(true)