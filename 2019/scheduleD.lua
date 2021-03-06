local document = require("document")
local node = require("node")

local m = {}
local mt = {
  name = "Schedule D (2019)",
  id = "Schedule D",
}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "1d",
  title = "Short-term proceeds",
  calculate = function(self)
    
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