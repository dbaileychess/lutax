-- draft as of September 11, 2019
-- https://www.irs.gov/pub/irs-dft/f1040--dft.pdf

local document = require("document")
local node = require("node")

local m = {}
local mt = {
  name = "Form 1040 (2019) Draft",
  id = "Form 1040",
}
setmetatable(mt, {__index = getmetatable(document)})

local taxRates = {0.1, 0.12, 0.22, 0.24, 0.32, 0.35, 0.37}

local function _calcTax(amount, caps, i)
  i = i or 1
  local rate = taxRates[i]
  local cap = caps[i] - (caps[i-1] or 0)
  if not cap or amount <= cap then return rate * amount end
  return rate*cap + _calcTax(amount - cap, caps, i + 1)
end

local function calculateTax(amount, taxBrackets)
  if amount <= 0 then return 0 end
  if amount < 100000 then
    amount = math.modf(amount / 50.0) * 50.0
  end
  return _calcTax(amount, taxBrackets, 1)
end

m.FilingStatus = {
  ["Single"] = {
    id = 1, 
    stdDeduct = 12200,
    taxBrackets = {9700,39475,84200,160725,204100,510300},
    },
  ["Married Filing Jointly"] = {
    id = 2, 
    stdDeduct = 24400,
    taxBrackets = {19400,78950,168400,321450,408200,612350},
    },
  ["Married Filing Separately"] = {
    id = 3,
    stdDeduct = 12200,
    taxBrackets = {9700,39475,84200,160725,204100,306175},
    },
  ["Head of household"] = {
    id = 4, 
    stdDeduct = 18350,
    taxBrackets = {13850,52850,84200,160700,204100,510300},
    },
  ["Qualifying window(er)"] = {
    id = 5, 
    stdDeduct = 24000,
    taxBrackets = {19400,78950,168400,321450,408200,612350},
    },
}  

local nodes = {
{
  line = "filingStatus",
  title = "Filing status:",
  default = "Single",
},
{
  line = "1",
  title = "Wages, salaries, tips, etc. Attach Form(s) W-2",
  calculate = function(self)
     -- grab all the W-2s and sum Line 1
    return self:SumAllAttachments("W-2", "1")
  end,  
},
{
  line = "2a",
  title = "Tax-exempt interest",
  calculate = function(self)
    -- grab all the 1099-int and sum Line 8
    return self:SumAllAttachments("1099-INT", "8")
  end,
},
{
  line = "2b",
  title = "Taxable interest. Attach Sch. B",
  calculate = function(self)
    -- grab Schedule B line 4
    return self:GetAttachmentValue("Schedule B", "4") or 0
  end,
},
{
  line = "3a",
  title = "Qualified Dividends",
  calculate = function(self)
    -- grab all the 1099-DIV and sum Line 1b
    return self:SumAllAttachments("1099-DIV", "1b")
  end,
},
{
  line = "3b",
  title = "Ordinary dividends. Attach Sch. B",
  calculate = function(self)
    -- grab all the 1099-cDIVE and sum Line 1a
    return self:SumAllAttachments("1099-DIV", "1a")
  end,
},
{
  line = "6",
  title = "Capital gain or (loss). Attach Schedule D if required.",
  calculate = function(self)
    return self:GetAttachmentValue("Schedule D", "21") or 0
  end,
},
{
  line = "7a",
  title = "Other income from Schedule 1, line 9",
  calculate = function(self)
    return self:GetAttachmentValue("Schedule 1", "9") or 0
  end,
},
{
  line = "7b",
  title = "Total income",
  calculate = function(self) 
    return self:SumNodeValues("1", "2b", "3b", "4b", "4d", "5b", "6", "7a")
  end,
},
{
  line = "8a",
  title = "Adjustments to income from Schedule 1, line 22",
  calculate = function(self)
    return self:GetAttachmentValue("Schedule 1", "22") or 0    
  end,
},
{
  line = "8b",
  title = "Subtract line 8a from line 7b. This is your adjusted gross income",
  calculate = function(self)
    return self:SubtractNodeValue("7b", "8a")
  end,
},
{
  line = "9",
  title = "Standard deduction or itemized deductions",
  calculate = function(self)
    local stdDeduct = self:GetFilingStatusData().stdDeduct
    local itemized = self:GetAttachmentValue("Schedule A", "17") or 0
    return math.max(stdDeduct, itemized)
  end,
},
{
  line = "10",
  title = "Qualified business income deduction.",
},
{
  line = "11a",
  title = "Add lines 9 and 10",
  calculate = function(self)
    return self:SumNodeValues("9", "10")
  end,
},
{
  line = "11b",
  title = "Taxable income",
  calculate = function(self)
    return math.max(self:SubtractNodeValue("8b", "11a"), 0)
  end,
},
{
  line = "12a",
  title = "Tax",
  calculate = function(self)
    local taxableIncome = self:GetNodeValue("11b")
    local filingData = self:GetFilingStatusData()
    return calculateTax(taxableIncome, filingData.taxBrackets)
  end,
  -- todo: handle the checkboxes 1, 2, 3 
},
{
  line = "12b",
  title = "Add Schedule 2, line 3 and line 12a and enter the total",
  calculate = function(self)
    return (self:GetAttachmentValue("Schedule 2", "3") or 0) + self:GetNodeValue("12a")
  end,
},
{
  line = "13a",
  title = "Child tax credit or credit for other dependents",
  -- todo
},
{
  line = "13b",
  title = "Add Schedule 3, line 7 and line 13a and enter the total",
  calculate = function(self)
    return (self:GetAttachmentValue("Schedule 3", "7") or 0) + self:GetNodeValue("13a")
  end,
},
{
  line = "14",
  title = "Subtract line 13b from line 12b. If zero or less, enter 0",
  calculate = function(self)
    return math.max(self:SubtractNodeValue("12b", "13b"), 0)
  end,
},
{
  line = "15",
  title = "Other taxes, including self-employment tax, from Schedule 2, line 10",
  calculate = function(self)
    return self:GetAttachmentValue("Schedule 2", "10")    
  end,
},
{
  line = "16",
  title = "Add lines 14 and 15. This is your total tax",
  calculate = function(self)
    return self:SumNodeValues("14", "15")    
  end,
},
{
  line = "17",
  title = "Federal income tax withheld from Forms W-2 and 1099",
  calculate = function(self)
    return self:SumAllAttachments("W-2", "2") 
    -- todo: it says or in the instructions for the following two fields
    -- need to investigate
    + self:SumAllAttachments("W-2G", "4")
    + self:SumAllAttachments("1099-R", "4")
  end,
},
{
  line = "18d",
  title = "Schedule 3, line 14",
  calculate = function(self)
    return self:GetAttachmentValue("Schedule 3", "14")
  end,
},
{
  line = "18e",
  title = "Add lines 18a through 18d. These are your total other payments and refundable credits",
  calculate = function(self)
    return self:SumNodeValues("18a", "18b", "18c", "18db")
  end,
},
{
  line = "19",
  title = "Add lines 17 and 18e. These are your total payments",
  calculate = function(self)
    return self:SumNodeValues("17", "18e")
  end,
},
{
  line = "20",
  title = "If line 19 is more than line 16, subtract line 16 from line 19. This is the amount you overpaid",
  calculate = function(self)
    local line19 = self:GetNodeValue("19")
    local line16 = self:GetNodeValue("16")
    if line19 > line16 then return line19 - line16 end
    return 0
  end,
},
}

function m.New(userName)
  local o = document.New({
      userName = userName,
      })
  setmetatable(o, {__index = mt})
  
  o:AddNodes(nodes)
  
  return o
end

function mt:GetFilingStatusData()
  local value = self:GetNodeValue("filingStatus")
  return assert(m.FilingStatus[value], "Not a valid filing status: "..value)
end

return m