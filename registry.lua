local m = {}

local reg = {}

function m.Add(node, context)
  local value = reg[node.id]
  if not value then
    value = {}
    value[context] = node
    reg[node.id] = value
  else 
    value[context] = node
  end
end

function m.Get(uuid, context)
  local value = reg[uuid]
  if not value then
    return nil
  end
  return value[context]
end

return m