-- https://www.irs.gov/pub/irs-pdf/f8283.pdf

local document = require("document")
local node = require("node")

local m = {}
local mt = {
  name = "Form 8283 (2019)",
  id = "Form 8283",
}
setmetatable(mt, {__index = getmetatable(document)})

local nodes = {
{
  line = "1ah",
  title = "Fair market value",
},
}

function m.New(userName)
  local o = document.New({
      userName = userName,
      })
  setmetatable(o, {__index = mt})
  
  o:AddNodes(nodes)
  
  return o
end


return m