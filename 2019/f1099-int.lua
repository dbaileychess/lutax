local document = require("document")
local node = require("node")

local m = {}
local mt = {}
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
      name = "1099-INT (2019)",
      id = "7153de10-e3a4-4a2b-acc0-6e2ede67564e",
      })
  setmetatable(o, {__index = mt})
  
  o:AddNodes(nodes)
  
  if inputData then
    o:AddInputs(inputData)
  end
  
  return o
end

return m