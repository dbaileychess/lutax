local document = require("document")
local node = require("node")
local sum = require("transformation").newAggregate


local m = {}
local mt = {}
setmetatable(mt, {__index = getmetatable(document)})

local n1 = {
    line = "1",
    title = "Wages, salaries, tips, etc. Attach Form(s) W-2",
    id = "61b95c2d-0ea8-46e6-8c5f-d5a50c6c2842",
    transform = sum(ofAttached("50f56bb9-e5ef-4fec-b8c0-b19abf5ae72d")) -- w2, line 1        
}

local n2b = {
    line = "2b",
    title = "Taxable interest",
    id = "874a8cb0-2aec-466c-8599-c384963ede89",
}

local n6 = {
    line = "6",
    title = "Total income",
    id = "ac15b3f2-6a5a-42a5-9451-914492aeed4e",
    transform = sum(
      "61b95c2d-0ea8-46e6-8c5f-d5a50c6c2842", -- line 1
      "874a8cb0-2aec-466c-8599-c384963ede89" -- line 2b
      ),
}

function m.New()
  local o = document.New({
      name = "Form 1040 (2019)",
      id = "bacc2341-acf8-49e6-b1f8-e4807bd29469",
      })
  setmetatable(o, {__index = mt})
  
  o:AddNode(n1)
  o:AddNode(n2b)
  o:AddNode(n6)
  
  return o
end

function mt:Attach(...)
  
end

function mt:AddInputs(data)
  for k,v in pairs(data) do
    
    self:SetValue(k, v)
  end
end



return m