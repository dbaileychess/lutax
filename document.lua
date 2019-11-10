local registry = require("registry")
local node = require("node")

local m = {}
local mt = {}
setmetatable(m, mt)

function m.New(data)
  local o = {
    userName = data.userName,
    name = data.name,
    id = data.id,
    nodes = {},
    attachments = {},
    }
  setmetatable(o, {__index = mt})
  return o
end

function mt:AddNode(nodeDef) 
  local n = node.New(nodeDef)
  self.nodes[n.line] = n
  registry.Add(n, self)
end

function mt:Attach(...)
  for k,v in ipairs{...} do
    local curValue = self.attachments[v.id]
    if curValue then
      curValue[#curValue + 1] = v
    else 
      self.attachments[v.id] = {v}
    end
  end
end

function mt:GetAttachments(documentId)
  return self.attachments[documentId]
end

function mt:AddInputs(data)
  for k,v in pairs(data) do
    self:SetValue(k, v)
  end
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

function mt:GetNodeValue(lineOrUuid)
  local node = self.nodes[lineOrUuid]
  if not node then 
    -- if we couldn't find it locally, try searching the registry
    node = registry.Get(lineOrUuid, self)
  end
  if not node then return nil end
  return node(self)
end

function mt:PrintOutput(includeAttachments)
  if includeAttachments then
    for _,attachments in pairs(self.attachments) do
      for _,attachment in ipairs(attachments) do
        attachment:PrintOutput(includeAttachments)
      end
    end
  end
  
  -- Print our own data out
  local usertext = self.userName and " ["..self.userName.."] " or " "
  print("== Form: "..self.name..usertext.."==")
  for k,v in pairs(self.nodes) do
    print("Line = ", v:GetLine(), " value = ",v:GetValue(self))
  end
  print()
end

return m