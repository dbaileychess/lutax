local document = require("document")
local node = require("node")

local m = {}
local mt = {
  name = "Schedule B (2019)",
  id = "Schedule B",
}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "1",
  title = "List name of payer",
  toString = function(self) 
    -- todo: figure a way to print out list of entries
  end,
},
{
  line = "2",
  title = "Add the amounts on line 1",
  calculate = function(self)
    local value = 0
    local interests = self:GetNodeValue("1")
    if not interests then return 0 end
    for _,interest in pairs(interests) do
      value = value + interest
    end
    return value
  end,
},
{
  line = "3",
  title = "Excludable interest on series EE and I U.S. savings bonds issued after 1989. Attach Form 8815",
  calculate = function(self)
    return 0 -- todo: form 8815
  end,
},
{
  line = "4",
  title = "Subtract line 3 from line 2. Enter the result here and on Form 1040 or 1040-SR, line 2b",
  calculate = function(self)
    return self:GetNodeValue("2") - self:GetNodeValue("3")
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