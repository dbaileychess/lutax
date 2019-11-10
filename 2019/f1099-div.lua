local document = require("document")
local node = require("node")

local m = {}
local mt = {}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "1b",
  title = "Qualified Dividends",
  id = "36f82c1d-87d2-49af-8f16-8b743532e02d",
},
}

function m.New(userName, inputData)
  local o = document.New({
      userName = userName,
      name = "1099-DIV (2019)",
      id = "2d158694-b9b3-4139-8cdb-9ddc04f1fd6f",
      })
  setmetatable(o, {__index = mt})
  
  o:AddNodes(nodes)
  
  if inputData then
    o:AddInputs(inputData)
  end
  
  return o
end

return m