local document = require("document")
local node = require("node")

local m = {}
local mt = {
  name = "1099-INT (2019)",
  id = "1099-INT",
}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "8",
  title = "Tax-exempt interest",
  id = "ede59e31-1294-4c0e-a1e8-a961d1ddcfea",
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