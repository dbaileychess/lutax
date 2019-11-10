local data = require("data")

-- Construct the forms with user-input data
local w2_personA = require("2019/w2").New("PersonA")
w2_personA:AddInputs(data.w2.personA)

local w2_personB = require("2019/w2").New()
w2_personB:AddInputs(data.w2.personB)

local f1040 = require("2019/f1040").New()
f1040:Attach(w2_personA, w2_personB)
f1040:AddInputs(data.f1040)

-- print out the completed form and all attachments
f1040:PrintOutput(true)