local document = require("document")
local node = require("node")

local m = {}
local mt = {
  name = "1099-DIV (2019)",
  id = "1099-DIV",
}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "1b",
  title = "Qualified Dividends",
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