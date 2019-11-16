local m = {}
local mt = {}

function m.New(data)
  local o = {
    document = data.document,
    line = data.line,
    title = data.title,
    calculate = data.calculate,
    default = data.default or 0
    }
  setmetatable(o, {__index = mt, __call = mt.GetValue})
  return o
end

function mt:GetValue(context)
  if self.calculate then
    self.value = self.calculate(context)
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

function mt:GetTitle()
  return self.title
end

return m