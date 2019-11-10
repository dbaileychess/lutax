local document = require("document")
local node = require("node")

local m = {}
local mt = { 
  name = "W-2 (2019)",
  id = "W-2",
}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "1",
  title = "Wages, tips, other compensation",
  id = "50f56bb9-e5ef-4fec-b8c0-b19abf5ae72d",
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