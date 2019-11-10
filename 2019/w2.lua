local document = require("document")
local node = require("node")


local m = {}
local mt = {}
setmetatable(mt, {__index = getmetatable(document)})

local n1 = {
    line = "1",
    title = "Wages, tips, other compensation",
    id = "50f56bb9-e5ef-4fec-b8c0-b19abf5ae72d",
}

function m.New(userName, inputData)
  local o = document.New({
      userName = userName,
      name = "W-2 (2019)",
      id = "856f8635-364b-4bab-a437-eabd9749e08e",
      })
  setmetatable(o, {__index = mt})
  
  o:AddNode(n1)
  if inputData then
    o:AddInputs(inputData)
  end
  return o
end

function mt:AddInputs(data)
  for k,v in pairs(data) do
        self:SetValue(k, v)
  end
end

return m