local registry = require("registry")

local m = {}
local mt = {}

local function aggregate(self, context)
  local value = 0;
  for k,v in ipairs(self.parts) do
    if type(v) == "string" then
      local node = registry.Get(v, context)
      assert(node, "Cannot find required node for transformation")
      value = value + node:GetValue(context)  
    else 
      for _,v2 in ipairs(v(context)) do
        value = value + v2:GetValue(context)
      end
    end
  end
  return value
end

local function ofAttached(self, context)
  local attachments = context:GetAttachments(self.documentUuid)
  local nodes = {}
  if not attachments then return nodes end
  for _,attachment in ipairs(attachments) do
    nodes[#nodes + 1] = registry.Get(self.nodeId, attachment)
  end
  return nodes
end

local function max(self, context)
  local maxValue = -1 -- todo: should this be even smaller?
  for _,v in ipairs(self.parts) do
    local calcValue = maxValue
    if type(v) == "number" then
      calcValue = v
    elseif type(v) == "string" then
      local node = assert(registry.Get(v, context))
      calcValue = node:GetValue(context)
    elseif type(v) == "table" then
      if v.isTransformation then        
        calcValue = v(context)
      else 
        calcValue = v:GetValue(context)
      end
    end
    
    if calcValue and calcValue > maxValue then maxValue = calcValue end
  end
  return maxValue
end

local function getRegistry(self, context)
  local node = registry.Get(self.nodeId, context)
  if not node then return nil end
  if self.func then
    return self.func(node, context)
  end
  return node
end  

function m.newAggregate(...)
  local o = {
    isTransformation = true,
    parts = {...}
  }
  setmetatable(o, {__call = aggregate})
  return o
end

function m.ofAttached(documentUuid, nodeId)
  local o = {
    isTransformation = true,
    documentUuid = documentUuid,
    nodeId = nodeId
  }
  setmetatable(o, {__call = ofAttached})
  return o
end

function m.max(...)
  local o = {
    isTransformation = true,
    parts = {...}
  }
  setmetatable(o, {__call = max})
  return o
end

-- Gets a node from the registry (given a context) and optionally perform a function
-- on that node if specified. This is useful to looking at the value of a node and making 
-- some decision based on the current value of the node.
function m.getNode(nodeId, func)
  local o = {
    isTransformation = true,
    nodeId = nodeId,
    func = func,
  }
  setmetatable(o, {__call = getRegistry})
  return o
end

return m