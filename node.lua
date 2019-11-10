local m = {}
local mt = {}

function m.New(data)
  local o = {
    document = data.document,
    line = data.line,
    id = data.id,
    transform = data.transform,
    }
  setmetatable(o, {__index = mt})
  return o
end

function mt:GetValue(context)
  local value
  if self.transform then
    value = self.transform:Compute(context)
    self.value = value
  end
  return self.value
end

function mt:SetValue(value)
  self.value = value
end

function mt:GetLine()
  return self.line
end

return m