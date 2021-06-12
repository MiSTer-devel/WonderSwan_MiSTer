--space.name = {address, upper, lower, size, default}
swan = {}
swan.Reg_swan_on = {1056768,0,0,1,0,"swan.Reg_swan_on"} -- on = 1
swan.Reg_swan_lockspeed = {1056769,0,0,1,0,"swan.Reg_swan_lockspeed"} -- 1 = 100% speed
swan.Reg_swan_TestDone = {1056770,0,0,1,0,"swan.Reg_swan_TestDone"}
swan.Reg_swan_TestOk   = {1056770,1,1,1,0,"swan.Reg_swan_TestOk"}
swan.Reg_swan_CyclePrecalc = {1056771,15,0,1,100,"swan.Reg_swan_CyclePrecalc"}
swan.Reg_swan_CyclesMissing = {1056772,31,0,1,0,"swan.Reg_swan_CyclesMissing"}
swan.Reg_swan_BusAddr = {1056773,27,0,1,0,"swan.Reg_swan_BusAddr"}
swan.Reg_swan_BusRnW = {1056773,28,28,1,0,"swan.Reg_swan_BusRnW"}
swan.Reg_swan_BusACC = {1056773,30,29,1,0,"swan.Reg_swan_BusACC"}
swan.Reg_swan_BusWriteData = {1056774,31,0,1,0,"swan.Reg_swan_BusWriteData"}
swan.Reg_swan_BusReadData = {1056775,31,0,1,0,"swan.Reg_swan_BusReadData"}
swan.Reg_swan_MaxPakAddr = {1056776,24,0,1,0,"swan.Reg_swan_MaxPakAddr"}
swan.Reg_swan_VsyncSpeed = {1056777,31,0,1,0,"swan.Reg_swan_VsyncSpeed"}
swan.Reg_swan_KeyUp = {1056778,0,0,1,0,"swan.Reg_swan_KeyUp"}
swan.Reg_swan_KeyDown = {1056778,1,1,1,0,"swan.Reg_swan_KeyDown"}
swan.Reg_swan_KeyLeft = {1056778,2,2,1,0,"swan.Reg_swan_KeyLeft"}
swan.Reg_swan_KeyRight = {1056778,3,3,1,0,"swan.Reg_swan_KeyRight"}
swan.Reg_swan_KeyA = {1056778,4,4,1,0,"swan.Reg_swan_KeyA"}
swan.Reg_swan_KeyB = {1056778,5,5,1,0,"swan.Reg_swan_KeyB"}
swan.Reg_swan_KeyL = {1056778,6,6,1,0,"swan.Reg_swan_KeyL"}
swan.Reg_swan_KeyR = {1056778,7,7,1,0,"swan.Reg_swan_KeyR"}
swan.Reg_swan_KeyStart = {1056778,8,8,1,0,"swan.Reg_swan_KeyStart"}
swan.Reg_swan_KeySelect = {1056778,9,9,1,0,"swan.Reg_swan_KeySelect"}
swan.Reg_swan_cputurbo = {1056780,0,0,1,0,"swan.Reg_swan_cputurbo"} -- 1 = cpu free running, all other 16 mhz
swan.Reg_swan_SramFlashEna = {1056781,0,0,1,0,"swan.Reg_swan_SramFlashEna"} -- 1 = enabled, 0 = disable (disable for copy protection in some games)
swan.Reg_swan_MemoryRemap = {1056782,0,0,1,0,"swan.Reg_swan_MemoryRemap"} -- 1 = enabled, 0 = disable (enable for copy protection in some games)
swan.Reg_swan_SaveState = {1056783,0,0,1,0,"swan.Reg_swan_SaveState"}
swan.Reg_swan_LoadState = {1056784,0,0,1,0,"swan.Reg_swan_LoadState"}
swan.Reg_swan_FrameBlend = {1056785,0,0,1,0,"swan.Reg_swan_FrameBlend"} -- mix last and current frame
swan.Reg_swan_Pixelshade = {1056786,2,0,1,0,"swan.Reg_swan_Pixelshade"} -- pixel shade 1..4, 0 = off
swan.Reg_swan_SaveStateAddr = {1056787,25,0,1,0,"swan.Reg_swan_SaveStateAddr"} -- address to save/load savestate
swan.Reg_swan_Rewind_on = {1056788,0,0,1,0,"swan.Reg_swan_Rewind_on"}
swan.Reg_swan_Rewind_active = {1056789,0,0,1,0,"swan.Reg_swan_Rewind_active"}
swan.Reg_swan_DEBUG_CPU_PC = {1056800,31,0,1,0,"swan.Reg_swan_DEBUG_CPU_PC"}
swan.Reg_swan_DEBUG_CPU_MIX = {1056801,31,0,1,0,"swan.Reg_swan_DEBUG_CPU_MIX"}
swan.Reg_swan_DEBUG_IRQ = {1056802,31,0,1,0,"swan.Reg_swan_DEBUG_IRQ"}
swan.Reg_swan_DEBUG_DMA = {1056803,31,0,1,0,"swan.Reg_swan_DEBUG_DMA"}
swan.Reg_swan_DEBUG_MEM = {1056804,31,0,1,0,"swan.Reg_swan_DEBUG_MEM"}
swan.Reg_swan_CHEAT_FLAGS = {1056810,31,0,1,0,"swan.Reg_swan_CHEAT_FLAGS"}
swan.Reg_swan_CHEAT_ADDRESS = {1056811,31,0,1,0,"swan.Reg_swan_CHEAT_ADDRESS"}
swan.Reg_swan_CHEAT_COMPARE = {1056812,31,0,1,0,"swan.Reg_swan_CHEAT_COMPARE"}
swan.Reg_swan_CHEAT_REPLACE = {1056813,31,0,1,0,"swan.Reg_swan_CHEAT_REPLACE"}
swan.Reg_swan_CHEAT_RESET = {1056814,0,0,1,0,"swan.Reg_swan_CHEAT_RESET"}