require("vsim_comm")
require("luareg")

wait_ns(10000)

reg_set(0, swan.Reg_swan_on)

reg_set_file("timingtest.ws", 0, 0, 0)


print("Game transfered")

reg_set_file("timingtest.sst", 58720256 + 0xC000000, 0, 0)

print("Savestate transfered")

wait_ns(10000)
reg_set(1, swan.Reg_swan_on)

--wait_ns(26000000)

reg_set(1, swan.Reg_swan_LoadState)

print("swan ON")

brk()