local registry = require("registry")

local m = {}

local mt = {}

local aggregateMt = {}

function aggregateMt:Compute(context)
  local value = 0;
  for k,v in ipairs(self.parts) do
    local node = registry.Get(v, context)
    if node then
      value = value + node:GetValue()
    else
      error("cannot find required node for transformation")
    end
  end
  return value
end

function m.newAggregate(...)
  local o = {
    parts = {...}
  }
  setmetatable(o, {__index = aggregateMt})
  return o
end

return m