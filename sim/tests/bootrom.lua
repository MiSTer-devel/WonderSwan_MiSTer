require("vsim_comm")
require("luareg")

wait_ns(10000)

reg_set(0, swan.Reg_swan_on)

reg_set_file(".wsc", 0, 0, 0)

wait_ns(10000)
reg_set(1, swan.Reg_swan_on)

print("swan ON")

brk()