local registry = require("registry")
local node = require("node")

local m = {}
local mt = {}
setmetatable(m, mt)

function m.New(data)
  local o = {
    name = data.name,
    id = data.id,
    nodes = {},
    }
  setmetatable(o, {__index = mt})
  return o
end

function mt:AddNode(nodeDef) 
  local n = node.New(nodeDef)
  self.nodes[n.line] = n
  registry.Add(n, self)
end

function mt:SetValue(identifier, value)
  local node
  if type(identifier) == "string" then
    node = self.nodes[identifier]
  elseif type(identifier) == "table" then
    node = self.nodes[identifier.id]
  else
    error("Cannot understand identifier type:",identifier, type(identifier))
  end
  
  assert(node, "Cannot find node for identifier:",identifier, type(identifier))
 
  node:SetValue(value)    
end

function mt:PrintOutput()
  for k,v in pairs(self.nodes) do
    print("Line = ", v:GetLine(), " value = ",v:GetValue(self))
  end
end

return m