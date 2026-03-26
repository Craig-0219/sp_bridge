SPTest = SPTest or {}

-- An item that is guaranteed to exist in the server's inventory system.
-- Change this to an item that exists in your item list.
SPTest.testItem   = 'bread'

-- Print individual PASS lines (true) or only show failures + summary (false).
SPTest.verbose    = true

-- true  → /sp_test requires ace permission `command.sp_test`
-- false → any player (or server console) can run /sp_test
SPTest.restricted = true
