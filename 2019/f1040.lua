-- draft as of September 11, 2019
-- https://www.irs.gov/pub/irs-dft/f1040--dft.pdf

local document = require("document")
local node = require("node")

local m = {}

m.FilingStatus = {
  ["Single"] = {id = 1, stdDeduct = 12200,},
  ["Married Filing Jointly"] = {id = 2, stdDeduct = 24400,},
  ["Married Filing Separately"] = {id = 3, stdDeduct = 12200,},
  ["Head of household"] = {id = 4, stdDeduct = 18350,},
  ["Qualifying window(er)"] = {id = 5, stdDeduct = 24000,},
}  

local mt = {}
setmetatable(mt, {__index = getmetatable(document)})

local filingStatus = {
    line = "filingStatus",
    title = "Filing status:",
    id = "aebf6a6e-c83f-434f-8925-9e54b610a94f",
}

local line1 = {
    line = "1",
    title = "Wages, salaries, tips, etc. Attach Form(s) W-2",
    id = "61b95c2d-0ea8-46e6-8c5f-d5a50c6c2842",
    transform = function(self)
      local value = 0
      -- grab all the W2s and sum Line 1
      for _,w2 in ipairs(self:GetAttachments("856f8635-364b-4bab-a437-eabd9749e08e")) do
        value = value + w2:GetNodeValue("1")
      end
      return value
    end,  
}

local line2b = {
    line = "2b",
    title = "Taxable interest. Attach Sch. B",
    id = "874a8cb0-2aec-466c-8599-c384963ede89",
}

local line3b = {
  line = "3b",
  title = "Ordinary dividends. Attach Sch. B",
  id = "dc94b674-6de6-45ba-a200-d85050efaa6c",
}

local line7b = {
    line = "7b",
    title = "Total income",
    id = "ac15b3f2-6a5a-42a5-9451-914492aeed4e",    
    transform = function(self) 
      return self:SumNodeValues("1", "2b", "3b", "4b", "4d", "5b", "6", "7a")
    end,
}

local line9 = {
    line = "9",
    title = "Standard deduction or itemized deductions",
    id = "cc7cac22-e1f8-4035-945c-332134e6911e",
    transform = function(self)
      local value = self:GetNodeValue("filingStatus")
      local filingData = m.FilingStatus[value]
      assert(filingData, "Not a valid filing status: "..value)
      local stdDeduct = filingData.stdDeduct
      return math.max(stdDeduct, 20123)
    end,
}

function m.New(userName)
  local o = document.New({
      userName = userName,
      name = "Form 1040 (2019)",
      id = "bacc2341-acf8-49e6-b1f8-e4807bd29469",
      })
  setmetatable(o, {__index = mt})
  
  o:AddNode(filingStatus)
  o:AddNode(line1)
  o:AddNode(line2b)
  o:AddNode(line3b)
  o:AddNode(line7b)
  o:AddNode(line9)
  
  return o
end

return m