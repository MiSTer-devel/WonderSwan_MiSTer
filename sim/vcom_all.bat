
vcom -93 -quiet -work  sim/tb ^
src/tb/globals.vhd

vcom -93 -quiet -work  sim/mem ^
src/mem/SyncRamDualByteEnable.vhd ^
src/mem/SyncFifo.vhd 

vcom -quiet -work  sim/rs232 ^
src/rs232/rs232_receiver.vhd ^
src/rs232/rs232_transmitter.vhd ^
src/rs232/tbrs232_receiver.vhd ^
src/rs232/tbrs232_transmitter.vhd

vcom -quiet -work sim/procbus ^
src/procbus/proc_bus.vhd ^
src/procbus/testprocessor.vhd

vcom -quiet -work sim/reg_map ^
src/reg_map/reg_swan.vhd

vcom -O5 -2008 -vopt -quiet -work sim/swan ^
../rtl/export.vhd

vcom -O5 -2008 -quiet -work sim/swan ^
../rtl/swanbios_sim.vhd ^
../rtl/swanbioscolor_sim.vhd ^
../rtl/dpram.vhd ^
../rtl/registerpackage.vhd ^
../rtl/reg_swan.vhd ^
../rtl/SyncRamDual.vhd ^
../rtl/SyncFifoFallThrough.vhd ^
../rtl/bus_savestates.vhd ^
../rtl/reg_savestates.vhd ^
../rtl/statemanager.vhd ^
../rtl/savestates.vhd ^
../rtl/dummyregs.vhd ^
../rtl/sound_module1.vhd ^
../rtl/sound_module2.vhd ^
../rtl/sound_module3.vhd ^
../rtl/sound_module4.vhd ^
../rtl/sound_module5.vhd ^
../rtl/sound.vhd ^
../rtl/joypad.vhd ^
../rtl/gpu_bg.vhd ^
../rtl/sprites.vhd ^
../rtl/gpu.vhd ^
../rtl/divider.vhd ^
../rtl/cpu.vhd ^
../rtl/dma.vhd ^
../rtl/eeprom.vhd ^
../rtl/memorymux.vhd ^
../rtl/IRQ.vhd ^
../rtl/rtc.vhd ^
../rtl/SwanTop.vhd

vlog -sv -quiet -work sim/tb ^
../rtl/ddram.sv

vcom -quiet -work sim/tb ^
src/tb/stringprocessor.vhd ^
src/tb/tb_interpreter.vhd ^
src/tb/framebuffer.vhd ^
src/tb/sdram_model.vhd ^
src/tb/ddrram_model.vhd ^
src/tb/tb.vhd