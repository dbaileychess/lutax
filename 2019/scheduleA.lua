local document = require("document")
local node = require("node")

local m = {}
local mt = {}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "1",
  title = "Medical and dental expenses",
  id = "e69a8413-cf78-4622-8d7c-2f86d62a2bc1",
},
{
  line = "2",
  title = "Enter amount from Form 1040 or 1040-SR, line 8b",
  id = "9956ec99-6bac-406a-b219-2bfac8214cfb",
  calculate = function(self)
    local f1040 = self:GetBackwardsAttachment("bacc2341-acf8-49e6-b1f8-e4807bd29469")
    assert(f1040, "Form 1040 needs to be backwards attached to this document")
    return f1040:GetNodeValue("8b")
  end,
},
{
  line = "3",
  title = "Multiple line 2 by 10% (0.10)",
  id = "21f8ead4-9dc5-42ca-b0c8-3a9c864c32a5",
  calculate = function(self)
    return 0.10 * self:GetNodeValue("2")
  end,
},
{
  line = "4",
  title = "Subtract line 3 from line 1. If line 3 is more than line 1, enter 0",
  id = "5a0131ce-c6a9-409b-b325-e57774442712",
  calculate = function(self)
    local line3 = self:GetNodeValue("3")
    local line1 = self:GetNodeValue("1")
    if line3 > line1 then return 0 end
    return line1 - line3
  end,
  },
}

function m.New(userName, inputData)
  local o = document.New({
      userName = userName,
      name = "Schedule A (2019)",
      id = "678aa2ad-e975-449c-a294-b3d3c4c729a2",
      })
  setmetatable(o, {__index = mt})
  
  o:AddNodes(nodes)
  
  if inputData then
    o:AddInputs(inputData)
  end
  
  return o
end

return m