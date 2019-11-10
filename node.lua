local m = {}
local mt = {}

function m.New(data)
  local o = {
    document = data.document,
    line = data.line,
    id = data.id,
    transform = data.transform,
    default = data.default or 0
    }
  setmetatable(o, {__index = mt, __call = mt.GetValue})
  return o
end

function mt:GetValue(context)
  if self.transform then
    self.value = self.transform(context)
  end
  if not self.value then return self.default end
  return self.value
end

function mt:SetValue(value)
  self.value = value
end

function mt:GetLine()
  return self.line
end

return m