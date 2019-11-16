local node = require("node")

local m = {}
local mt = {}
setmetatable(m, mt)

function m.New(data)
  local o = {
    userName = data.userName,
    name = data.name,
    nodes = {},
    attachments = {},
    backAttachments = {},
    }
  setmetatable(o, {__index = mt})
  return o
end

function mt:AddNodes(nodeDefs)
  for _,nodeData in ipairs(nodeDefs) do
    self:AddNode(nodeData)
  end
end

function mt:AddNode(nodeDef) 
  local n = node.New(nodeDef)
  self.nodes[n.line] = n
  self.nodes[#self.nodes + 1] = n -- add in sorted order as well
end

function mt:Attach(...)
  for k,v in ipairs{...} do
    if not v.id and type(v) == "table" then
      self:Attach(table.unpack(v))
    else
      local curValue = self.attachments[v.id]
      if curValue then
        curValue[#curValue + 1] = v
      else 
        self.attachments[v.id] = {v}
      end
      v:BackwardsAttach(self)
    end
  end
end

function mt:GetAttachments(documentId)
  return self.attachments[documentId]
end

function mt:BackwardsAttach(other)
  -- todo: can you have multiple backwards attachments of the same type?
  self.backAttachments[other.id] = other
end

function mt:GetBackwardsAttachment(documentId)
  return self.backAttachments[documentId]
end

function mt:GetAttachment(documentId, nodeId)
  local attachment = self.attachments[documentId]
  if not attachment then return nil end
  assert(#attachment == 1, "Only one attachment of id: ",documentId," is expected")
  attachment = attachment[1]
  if nodeId then return attachment[nodeId] end
  return attachment
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

function mt:GetNodeValue(id)
  local node = self.nodes[id]
  if not node then return nil end
  return node(self)
end

function mt:SumNodeValues(...)
  local value = 0
  for _,id in ipairs{...} do
    local nodeValue = self:GetNodeValue(id)
    -- todo: we should assert when a node is missing, that means
    -- document is not correctly defined.
    if nodeValue then 
      value = value + self:GetNodeValue(id)
    end
  end
  return value
end

function mt:SubtractNodeValue(baseId, ...)
  local value = self:GetNodeValue(baseId)
  for _,id in ipairs{...} do
    value = value - self:GetNodeValue(id)
  end
  return value
end

-- For all attachments given the specified attachmentId, sum all the node values
-- passed into the varags ...
function mt:SumAllAttachments(attachmentId, ...)
  local attachments = self:GetAttachments(attachmentId)
  if not attachments then return 0 end
  local value = 0
  for _,attachment in ipairs(attachments) do
    value = value + attachment:SumNodeValues(...)
  end
  return value
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
  for k,v in ipairs(self.nodes) do
    print("Line = ", v:GetLine(), " value = ",v:GetValue(self))
  end
  print()
end

return m