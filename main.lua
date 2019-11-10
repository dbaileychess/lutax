local data = require("data")

local f1040 = require("2019/f1040").New()
local w2_personA = require("2019/w2").New()
local w2_personB = require("2019/w2").New()

w2_personA:AddInputs(data.w2.personA)
w2_personB:AddInputs(data.w2.personB)

f1040:Attach(w2_personA, w2_personB)
f1040:AddInputs(data.f1040)

f1040:PrintOutput()