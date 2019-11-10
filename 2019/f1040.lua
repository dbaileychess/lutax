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

local singleTax = function(amount) 
  if amount < 100000 then
    return 0 -- todo
  elseif amount <= 160725 then
    return amount * 0.24 - 5825.50
  elseif amount <= 204100 then
    return amount * 0.32 - 18683.50
  elseif amount < 510300 then
    return amount * 0.35 - 24806.50
  else
    return amount * 0.37 - 35012.50
  end
end

m.FilingStatus = {
  ["Single"] = {
    id = 1, 
    stdDeduct = 12200,
    tax = singleTax,
    },
  ["Married Filing Jointly"] = {
    id = 2, 
    stdDeduct = 24400,
    tax = singleTax,
    },
  ["Married Filing Separately"] = {id = 3, stdDeduct = 12200,},
  ["Head of household"] = {id = 4, stdDeduct = 18350,},
  ["Qualifying window(er)"] = {id = 5, stdDeduct = 24000,},
}  

local nodes = {
{
  line = "filingStatus",
  title = "Filing status:",
  id = "aebf6a6e-c83f-434f-8925-9e54b610a94f",
  default = "Single",
},
{
  line = "1",
  title = "Wages, salaries, tips, etc. Attach Form(s) W-2",
  id = "61b95c2d-0ea8-46e6-8c5f-d5a50c6c2842",
  calculate = function(self)
     -- grab all the W-2s and sum Line 1
    return self:SumAllAttachments("W-2", "1")
  end,  
},
{
  line = "2a",
  title = "Tax-exempt interest",
  id = "8dae0c43-f221-425b-96fd-a273c537ab2a",
  calculate = function(self)
    -- grab all the 1099-int and sum Line 8
    return self:SumAllAttachments("1099-INT", "8")
  end,
},
{
  line = "2b",
  title = "Taxable interest. Attach Sch. B",
  id = "874a8cb0-2aec-466c-8599-c384963ede89",
  calculate = function(self)
    -- grab Schedule B line 4
    return self:GetAttachment("Schedule B", "4") or 0
  end,
},
{
  line = "3a",
  title = "Qualified Dividends",
  id = "2d8d4d93-b00a-48fc-ba94-9fe01136fdb4",
  calculate = function(self)
    -- grab all the 1099-int and sum Line 1b
    return self:SumAllAttachments("1099-INT", "1b")
  end,
},
{
  line = "3b",
  title = "Ordinary dividends. Attach Sch. B",
  id = "dc94b674-6de6-45ba-a200-d85050efaa6c",
  calculate = function(self)
    -- grab all the 1099-int and sum Line 1a
    return self:SumAllAttachments("1099-INT", "1a")
  end,
},
{
  line = "7a",
  title = "Other income from Schedule 1, line 9",
  id = "c94916ad-823d-4a0a-a79e-55f205c38dcf",
  calculate = function(self)
    -- grab Schedule 1 line 9
    return self:GetAttachment("Schedule 1", "9") or 0
  end,
},
{
  line = "7b",
  title = "Total income",
  id = "ac15b3f2-6a5a-42a5-9451-914492aeed4e",    
  calculate = function(self) 
    return self:SumNodeValues("1", "2b", "3b", "4b", "4d", "5b", "6", "7a")
  end,
},
{
  line = "8a",
  title = "Adjustments to income from Schedule 1, line 22",
  id = "c8b0317c-e812-402f-bb65-61248466f412",
  calculate = function(self)
    -- grab Schedule 1 line 22
    return self:GetAttachment("Schedule 1", "22")    
  end,
},
{
  line = "8b",
  title = "Subtract line 8a from line 7b. This is your adjusted gross income",
  id = "bf50bd82-46b3-4740-a47d-71e956746ca6",
  calculate = function(self)
    return self:SubtractNodeValue("7b", "8a")
  end,
},
{
  line = "9",
  title = "Standard deduction or itemized deductions",
  id = "cc7cac22-e1f8-4035-945c-332134e6911e",
  calculate = function(self)
    local filingData = self:GetFilingStatusData()
    local stdDeduct = filingData.stdDeduct
    return math.max(stdDeduct, 20123)
  end,
},
{
  line = "10",
  title = "Qualified business income deduction.",
  id = "94934fb8-ffff-44c7-8907-871989b64313",  
},
{
  line = "11a",
  title = "Add lines 9 and 10",
  id = "3db939b4-64ab-401a-b68a-f9a8e2a99839",
  calculate = function(self)
    return self:SumNodeValues("9", "10")
  end,
},
{
  line = "11b",
  title = "Taxable income",
  id = "7e2b1d94-1eed-4d46-9c97-0e61c5f12972",  
  calculate = function(self)
    return math.max(self:SubtractNodeValue("8b", "11a"), 0)
  end,
},
{
  line = "12a",
  title = "Tax",
  id = "1e030d18-dd35-4e6c-b297-0d8f358ea64e",
  calculate = function(self)
    local taxableIncome = self:GetNodeValue("11b")
    local filingData = self:GetFilingStatusData()
    return filingData.tax(taxableIncome)
  end,
  -- todo: handle the checkboxes 1, 2, 3 
},
{
  line = "12b",
  title = "Add Schedule 2, line 3 and line 12a and enter the total",
  id = "fda3fe7e-40d4-4f23-a6f4-6a703b0fda41",
  calculate = function(self)
    return (self:GetAttachment("Schedule 2", "3") or 0) + self:GetNodeValue("12a")
  end,
},
{
  line = "13a",
  title = "Child tax credit or credit for other dependents",
  id = "b5ed8a86-4281-44bf-ade9-821867408a75",
  -- todo
},
{
  line = "13b",
  title = "Add Schedule 3, line 7 and line 13a and enter the total",
  id = "17427659-8a25-40c8-bd9d-16b93c5b9a54",
  calculate = function(self)
    return (self:GetAttachment("Schedule 3", "7") or 0) + self:GetNodeValue("13a")
  end,
},
{
  line = "14",
  title = "Subtract line 13b from line 12b. If zero or less, enter 0",
  id = "1221ba38-98bc-470b-8687-e96762817211",
  calculate = function(self)
    return math.max(self:SubtractNodeValue("12b", "13b"), 0)
  end,
},
{
  line = "15",
  title = "Other taxes, including self-employment tax, from Schedule 2, line 10",
  id = "249a84e5-66ab-489a-ae3f-ed708507bbb9",
  calculate = function(self)
    return self:GetAttachment("Schedule 2", "10")    
  end,
},
{
  line = "16",
  title = "Add lines 14 and 15. This is your total tax",
  id = "2abbaf23-788b-4929-90c6-ebf038cd1315",
  calculate = function(self)
    return self:SumNodeValues("14", "15")    
  end,
},
{
  line = "17",
  title = "Federal income tax withheld from Forms W-2 and 1099",
  id = "ea3a2295-b724-409c-8ba3-b653d11690be",
  calculate = function(self)
    return self:SumAllAttachments("W-2", "2") 
    -- todo: it says or in the instructions for the following two fields
    -- need to investigate
    + self:SumAllAttachments("W-2G", "4")
    + self:SumAllAttachments("1099-R", "4")
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