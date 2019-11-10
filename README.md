# lutax
Tax filing software in Lua

**This is still in early stage development, it is no where near complete or verified.**

Purpose
=======

A simple toolbox to help those who like to fill their taxes in by hand.

Of course there are many online tools, and paid companies, that can help in preparing tax documents. But I haven't seen an open-source project of this nature.

Usage
=====

See [main.lua](main.lua) for a complete, workable example.

Simply load the Tax forms/documents you need to fill out as Lua modules:

```lua
local f1040Form = require("2019/f1040")
local f1040 = f1040Form.New()
```

Load the data you need to provide and attach any other documents:

```lua
f1040:Attach(w2s)
f1040:AddInputs(data.f1040)
````

And then generate the finalized documents:

```lua
f1040:PrintOutput(true)
```

Results in:

```sh
== Form: W-2 (2019) [personA] ==
Line = 	1	 value = 	35132.31

== Form: W-2 (2019) [personB] ==
Line = 	1	 value = 	74312.12

== Form: Form 1040 (2019) Draft ==
Line = 	filingStatus	 value = 	Married Filing Jointly
Line = 	1	 value = 	109444.43
Line = 	2b	 value = 	1234.12
Line = 	3b	 value = 	0
Line = 	7b	 value = 	110678.55
Line = 	8a	 value = 	0
Line = 	8b	 value = 	110678.55
Line = 	9	 value = 	24400
```
