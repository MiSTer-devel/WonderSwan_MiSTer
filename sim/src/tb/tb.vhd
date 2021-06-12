library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;     

library tb;
library swan;

library procbus;
use procbus.pProc_bus.all;
use procbus.pRegmap.all;

library reg_map;
use reg_map.pReg_swan.all;

entity etb  is
end entity;

architecture arch of etb is

   constant clk_speed : integer := 30000000;
   constant baud      : integer := 3000000;
 
   signal reset       : std_logic := '1';
   signal clksys      : std_logic := '1';
   signal clkram      : std_logic := '1';
   
   signal command_in  : std_logic;
   signal command_out : std_logic;
   signal command_out_filter : std_logic;
   
   signal proc_bus_in : proc_bus_type;
   
   signal cart_addr : std_logic_vector(15 downto 0);
   signal cart_rd   : std_logic;
   signal cart_wr   : std_logic;
   signal cart_act  : std_logic;
   signal cart_do   : std_logic_vector(7 downto 0);
   signal cart_di   : std_logic_vector(7 downto 0);
   
   signal pixel_out_addr : integer range 0 to 32255;
   signal pixel_out_data : std_logic_vector(11 downto 0);  
   signal pixel_out_we   : std_logic := '0';       
   
   -- rom read
   signal maskAddr         : std_logic_vector(23 downto 0);
   signal romtype          : std_logic_vector(7 downto 0);
   signal ramtype          : std_logic_vector(7 downto 0);
   signal hasRTC           : std_logic; 
   signal isColor          : std_logic; 
   
   --sdram access
   signal EXTRAM_doRefresh : std_logic;
   signal EXTRAM_read      : std_logic;
   signal EXTRAM_write     : std_logic;
   signal EXTRAM_be        : std_logic_vector(1 downto 0);
   signal EXTRAM_addr      : std_logic_vector(24 downto 0);
   signal EXTRAM_datawrite : std_logic_vector(15 downto 0);
   signal EXTRAM_dataread  : std_logic_vector(15 downto 0);
   
   -- ddrram
   signal DDRAM_CLK        : std_logic;
   signal DDRAM_BUSY       : std_logic;
   signal DDRAM_BURSTCNT   : std_logic_vector(7 downto 0);
   signal DDRAM_ADDR       : std_logic_vector(28 downto 0);
   signal DDRAM_DOUT       : std_logic_vector(63 downto 0);
   signal DDRAM_DOUT_READY : std_logic;
   signal DDRAM_RD         : std_logic;
   signal DDRAM_DIN        : std_logic_vector(63 downto 0);
   signal DDRAM_BE         : std_logic_vector(7 downto 0);
   signal DDRAM_WE         : std_logic;
   
   signal ch1_addr         : std_logic_vector(27 downto 1);
   signal ch1_dout         : std_logic_vector(63 downto 0);
   signal ch1_din          : std_logic_vector(63 downto 0);
   signal ch1_be           : std_logic_vector( 7 downto 0);
   signal ch1_req          : std_logic;
   signal ch1_rnw          : std_logic;
   signal ch1_ready        : std_logic;
   
   signal SAVE_out_Din     : std_logic_vector(63 downto 0);
   signal SAVE_out_Dout    : std_logic_vector(63 downto 0);
   signal SAVE_out_Adr     : std_logic_vector(25 downto 0);
   signal SAVE_out_be      : std_logic_vector( 7 downto 0);
   signal SAVE_out_rnw     : std_logic;                    
   signal SAVE_out_ena     : std_logic;                                    
   signal SAVE_out_done    : std_logic; 
   
   -- settings
   signal swan_on            : std_logic_vector(Reg_swan_on.upper             downto Reg_swan_on.lower)             := (others => '0');
   signal swan_SaveState     : std_logic_vector(Reg_swan_SaveState.upper      downto Reg_swan_SaveState.lower)      := (others => '0');
   signal swan_LoadState     : std_logic_vector(Reg_swan_LoadState.upper      downto Reg_swan_LoadState.lower)      := (others => '0'); 
   signal swan_Rewind_on     : std_logic_vector(Reg_swan_Rewind_on    .upper  downto Reg_swan_Rewind_on    .lower)  := (others => '0'); 
   signal swan_Rewind_active : std_logic_vector(Reg_swan_Rewind_active.upper  downto Reg_swan_Rewind_active.lower)  := (others => '0'); 
   
   
begin

   reset  <= not swan_on(0);
   clksys <= not clksys after 30 ns;
   clkram <= not clkram after 10 ns;
   
   -- registers
   iReg_swan_on             : entity procbus.eProcReg generic map (Reg_swan_on           ) port map (clksys, proc_bus_in, swan_on           , swan_on       );      
   iReg_swan_SaveState      : entity procbus.eProcReg generic map (Reg_swan_SaveState    ) port map (clksys, proc_bus_in, swan_SaveState    , swan_SaveState);      
   iReg_swan_LoadState      : entity procbus.eProcReg generic map (Reg_swan_LoadState    ) port map (clksys, proc_bus_in, swan_LoadState    , swan_LoadState);
   iReg_swan_Rewind_on      : entity procbus.eProcReg generic map (Reg_swan_Rewind_on    ) port map (clksys, proc_bus_in, swan_Rewind_on    , swan_Rewind_on    );
   iReg_swan_Rewind_active  : entity procbus.eProcReg generic map (Reg_swan_Rewind_active) port map (clksys, proc_bus_in, swan_Rewind_active, swan_Rewind_active);
   
   iSwanTop : entity Swan.SwanTop
   generic map
   (
      is_simu => '1'
   )
   port map
   (
      clk                        => clksys,  
      clk_ram                    => '0',  
      reset_in	                  => reset,
      pause_in	                  => '0',
      
      eepromWrite                => open,
      eeprom_addr                => (9 downto 0 => '0'),
      eeprom_din                 => (15 downto 0 => '0'), 
      eeprom_dout                => open,
      eeprom_req                 => '0', 
      eeprom_rnw                 => '1', 
      
      -- rom
      EXTRAM_doRefresh           => EXTRAM_doRefresh,     
      EXTRAM_read                => EXTRAM_read,     
      EXTRAM_write               => EXTRAM_write,    
      EXTRAM_be                  => EXTRAM_be,    
      EXTRAM_addr                => EXTRAM_addr,     
      EXTRAM_datawrite           => EXTRAM_datawrite,
      EXTRAM_dataread            => EXTRAM_dataread, 
      
      maskAddr                   => maskAddr,
      romtype                    => romtype,
      ramtype                    => ramtype,
      hasRTC                     => hasRTC, 
      
      -- bios
      bios_wraddr                => (others => '0'),
      bios_wrdata                => (others => '0'),
      bios_wr                    => '0',
      bios_wrcolor               => '0',
                    
      -- video                   
      pixel_out_addr             => pixel_out_addr,
      pixel_out_data             => pixel_out_data,
      pixel_out_we               => pixel_out_we,  
                                 
      -- audio                   
      audio_l 	                  => open,
      audio_r 	                  => open,
      
      -- settings
      isColor                    => isColor,
      fastforward                => '1',
      turbo                      => '0',
      
      -- JOYSTICK
      KeyY1                      => '0',
      KeyY2                      => '0',
      KeyY3                      => '0',
      KeyY4                      => '0',
      KeyX1                      => '0',
      KeyX2                      => '0',
      KeyX3                      => '0',
      KeyX4                      => '0',
      KeyStart                   => '0',
      KeyA                       => '0',
      KeyB                       => '0',
      
      -- RTC
      RTC_timestampNew   => '0',
      RTC_timestampIn    => x"00001E10", -- one hour
      RTC_timestampSaved => x"00001000",
      RTC_savedtimeIn    => x"19" & "10010" & "110001" & "110" & "100011" & "1011001" & "1011001",
      RTC_saveLoaded     => '0',
      RTC_timestampOut   => open,
      RTC_savedtimeOut   => open,
                                 
      -- savestates              
      increaseSSHeaderCount      => '0',
      save_state                 => swan_SaveState(0),
      load_state                 => swan_LoadState(0),
      savestate_number           => 0,
      state_loaded               => open,
                    
      SAVE_out_Din               => SAVE_out_Din,                 
      SAVE_out_Dout              => SAVE_out_Dout,         
      SAVE_out_Adr               => SAVE_out_Adr, 
      SAVE_out_rnw               => SAVE_out_rnw, 
      SAVE_out_ena               => SAVE_out_ena, 
      SAVE_out_be                => SAVE_out_be, 
      SAVE_out_done              => SAVE_out_done,
                       
      rewind_on                  => swan_Rewind_on(0),
      rewind_active              => swan_Rewind_active(0)
   );
   
   isdram_model : entity tb.sdram_model 
   port map
   (
      clk               => clkram,
      doRefresh         => EXTRAM_doRefresh,
      addr              => EXTRAM_addr(24 downto 1),
      rd                => EXTRAM_read, 
      wr                => EXTRAM_write,
      be                => EXTRAM_be,
      di                => EXTRAM_datawrite,
      do                => EXTRAM_dataread, 
      maskAddr          => maskAddr,
      romtype           => romtype,
      ramtype           => ramtype,
      hasRTC            => hasRTC,
      isColor           => isColor
   );
   
   
   ch1_addr <= SAVE_out_Adr(25 downto 0) & "0";
   ch1_din  <= SAVE_out_Din;
   ch1_req  <= SAVE_out_ena;
   ch1_rnw  <= SAVE_out_rnw;
   ch1_be   <= SAVE_out_be;
   SAVE_out_Dout <= ch1_dout;
   SAVE_out_done <= ch1_ready;
   
   iddrram : entity tb.ddram
   port map (
      DDRAM_CLK        => clksys,      
      DDRAM_BUSY       => DDRAM_BUSY,      
      DDRAM_BURSTCNT   => DDRAM_BURSTCNT,  
      DDRAM_ADDR       => DDRAM_ADDR,      
      DDRAM_DOUT       => DDRAM_DOUT,      
      DDRAM_DOUT_READY => DDRAM_DOUT_READY,
      DDRAM_RD         => DDRAM_RD,        
      DDRAM_DIN        => DDRAM_DIN,       
      DDRAM_BE         => DDRAM_BE,        
      DDRAM_WE         => DDRAM_WE,                
                                   
      ch1_addr         => ch1_addr,        
      ch1_dout         => ch1_dout,        
      ch1_din          => ch1_din,         
      ch1_req          => ch1_req,         
      ch1_rnw          => ch1_rnw, 
      ch1_be           => ch1_be,
      ch1_ready        => ch1_ready
   );
   
   iddrram_model : entity tb.ddrram_model
   port map
   (
      DDRAM_CLK        => clksys,      
      DDRAM_BUSY       => DDRAM_BUSY,      
      DDRAM_BURSTCNT   => DDRAM_BURSTCNT,  
      DDRAM_ADDR       => DDRAM_ADDR,      
      DDRAM_DOUT       => DDRAM_DOUT,      
      DDRAM_DOUT_READY => DDRAM_DOUT_READY,
      DDRAM_RD         => DDRAM_RD,        
      DDRAM_DIN        => DDRAM_DIN,       
      DDRAM_BE         => DDRAM_BE,        
      DDRAM_WE         => DDRAM_WE        
   );

   
   iframebuffer : entity work.framebuffer
   generic map
   (
      FRAMESIZE_X => 224,
      FRAMESIZE_Y => 144
   )
   port map
   (
      clk                => clksys,
                          
      pixel_in_addr      => pixel_out_addr,
      pixel_in_data      => pixel_out_data,
      pixel_in_we        => pixel_out_we
   );
   
   iTestprocessor : entity procbus.eTestprocessor
   generic map
   (
      clk_speed => clk_speed,
      baud      => baud,
      is_simu   => '1'
   )
   port map 
   (
      clk               => clksys,
      bootloader        => '0',
      debugaccess       => '1',
      command_in        => command_in,
      command_out       => command_out,
            
      proc_bus          => proc_bus_in,
      
      fifo_full_error   => open,
      timeout_error     => open
   );
   
   command_out_filter <= '0' when command_out = 'Z' else command_out;
   
   itb_interpreter : entity tb.etb_interpreter
   generic map
   (
      clk_speed => clk_speed,
      baud      => baud
   )
   port map
   (
      clk         => clksys,
      command_in  => command_in, 
      command_out => command_out_filter
   );
   
end architecture;


