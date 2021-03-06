local document = require("document")
local node = require("node")

local m = {}
local mt = {
  name = "Schedule A (2019)",
  id = "Schedule A",
}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "1",
  title = "Medical and dental expenses",
},
{
  line = "2",
  title = "Enter amount from Form 1040 or 1040-SR, line 8b",
  calculate = function(self)
    local f1040 = self:GetBackwardsAttachment("Form 1040")
    assert(f1040, "Form 1040 needs to be backwards attached to this document")
    return f1040:GetNodeValue("8b")
  end,
},
{
  line = "3",
  title = "Multiple line 2 by 7.50% (0.075)",
  calculate = function(self)
    return 0.075 * self:GetNodeValue("2")
  end,
},
{
  line = "4",
  title = "Subtract line 3 from line 1. If line 3 is more than line 1, enter 0",
  calculate = function(self)
    local line3 = self:GetNodeValue("3")
    local line1 = self:GetNodeValue("1")
    if line3 > line1 then return 0 end
    return line1 - line3
  end,
},
{
  line = "5a",
  title = "State and local taxes",
  calculate = function(self)
    local f1040 = self:GetBackwardsAttachment("Form 1040")
    return f1040:SumAllAttachments("W-2", "17")
  end,
},
{ 
  line = "5d",
  title = "Add lines 5a through 5c",
  calculate = function(self) 
    return self:SumNodeValues("5a")
  end,
},
{
  line = "5e",
  title = "Enter the smaller of line 5d or $10,000 ($5,000) if married filing separately",
  calculate = function(self)
    local f1040 = self:GetBackwardsAttachment("Form 1040")
    local filingStatus = f1040:GetNodeValue("filingStatus")
    local max = filingStatus == "Married Filing Separately" and 5000 or 10000
    return math.min(max, self:GetNodeValue("5d"))
  end,
},
{
  line = "7",
  title = "Add lines 5e and 6",
  calculate = function(self)
    return self:SumNodeValues("5e", "6")
  end,
  },
{ 
  line = "11",
  title = "Gifts by cash or check",
},
{ 
  line = "12",
  title = "Gifts other than by cash or check",
  calculate = function(self)
    -- todo: this should sum all the h columns
    return self:GetAttachmentValue("Form 8283", "1ah") or 0
  end,
},
{
  line = "17",
  title = "Add the amounts in the far right column for lines 4 through 16. Also, enter this amount on Form 1040 or 1040-SR, line 9",
  calculate = function(self)
    return self:SumNodeValues("4", "7", "10", "11", "12", "14", "15", "16")
  end,
},
}

function m.New(userName, inputData)
  local o = document.New({
    userName = userName,
  })
  setmetatable(o, {__index = mt})
  
  o:AddNodes(nodes)
  
  if inputData then
    o:AddInputs(inputData)
  end
  
  return o
end

return m