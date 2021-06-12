library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;     

library tb;
use tb.globals.all;

entity sdram_model is
   port 
   (
      clk               : in  std_logic;
      doRefresh         : in  std_logic;
      addr              : in  std_logic_vector(23 downto 0);
      rd                : in  std_logic;
      wr                : in  std_logic;
      be                : in  std_logic_vector(1 downto 0);
      di                : in  std_logic_vector(15 downto 0);
      do                : out std_logic_vector(15 downto 0);
      maskAddr          : out std_logic_vector(23 downto 0) := (others => '0');
      romtype           : out std_logic_vector(7 downto 0) := (others => '0');
      ramtype           : out std_logic_vector(7 downto 0) := (others => '0');
      hasRTC            : out std_logic;
      isColor           : out std_logic 
   );
end entity;

architecture arch of sdram_model is

   -- not full size, because of memory required
   type t_data is array(0 to (2**25)-1) of integer;
   type bit_vector_file is file of bit_vector;
   
   signal refreshCnt : integer range 0 to 499 := 0;
   signal waitcnt    : integer range 0 to 8 := 0;
   signal isRefresh  : std_logic := '0';
   signal rd_1       : std_logic := '0';
   signal wr_1       : std_logic := '0';
   
   
begin

   process
   
      variable data           : t_data := (others => 0);
      variable bs93           : std_logic;
      
      file infile             : bit_vector_file;
      variable f_status       : FILE_OPEN_STATUS;
      variable read_byte      : std_logic_vector(7 downto 0);
      variable next_vector    : bit_vector (0 downto 0);
      variable actual_len     : natural;
      variable targetpos      : integer;
      
      -- copy from std_logic_arith, not used here because numeric std is also included
      function CONV_STD_LOGIC_VECTOR(ARG: INTEGER; SIZE: INTEGER) return STD_LOGIC_VECTOR is
        variable result: STD_LOGIC_VECTOR (SIZE-1 downto 0);
        variable temp: integer;
      begin
 
         temp := ARG;
         for i in 0 to SIZE-1 loop
 
         if (temp mod 2) = 1 then
            result(i) := '1';
         else 
            result(i) := '0';
         end if;
 
         if temp > 0 then
            temp := temp / 2;
         elsif (temp > integer'low) then
            temp := (temp - 1) / 2; -- simulate ASR
         else
            temp := temp / 2; -- simulate ASR
         end if;
        end loop;
 
        return result;  
      end;
   
   begin
      wait until rising_edge(clk);
      
      if (refreshCnt < 499) then
         refreshCnt <= refreshCnt + 1;
      else
         report "SDRAM Refresh not happened in time" severity failure;
      end if;
      
      if (waitcnt > 0) then
         waitcnt <= waitcnt - 1;
         if (waitcnt = 1) then
            if (isRefresh = '0') then
               do  <= std_logic_vector(to_unsigned(data(to_integer(unsigned(addr)) * 2 + 1), 8)) & std_logic_vector(to_unsigned(data(to_integer(unsigned(addr)) * 2), 8));
            end if;
         end if;
      elsif (wr = '1' and wr_1 = '0') then
         if (be(1) = '1') then data(to_integer(unsigned(addr)) * 2 + 1) := to_integer(unsigned(di(15 downto 8))); end if;
         if (be(0) = '1') then data(to_integer(unsigned(addr)) * 2 + 0) := to_integer(unsigned(di( 7 downto 0))); end if;
         isRefresh <= '0'; 
         waitcnt   <= 8;
      elsif (rd = '1' and rd_1 = '0') then
         do        <= (others => 'X');
         isRefresh <= '0'; 
         waitcnt   <= 8;
      elsif (doRefresh = '1') then
         isRefresh  <= '1';
         refreshCnt <= 0;
         waitcnt    <= 5;
      end if;
      
      rd_1 <= rd;
      if (rd = '1' and rd_1 = '0' and waitcnt > 0) then
         report "Read while sdram busy" severity failure;
      end if;
      
      wr_1 <= wr;
      if (wr = '1' and wr_1 = '0' and waitcnt > 0) then
         report "Write while sdram busy" severity failure;
      end if;
      

      COMMAND_FILE_ACK_1 <= '0';
      if COMMAND_FILE_START_1 = '1' then
         
         assert false report "received" severity note;
         assert false report COMMAND_FILE_NAME(1 to COMMAND_FILE_NAMELEN) severity note;
      
         file_open(f_status, infile, COMMAND_FILE_NAME(1 to COMMAND_FILE_NAMELEN), read_mode);
      
         targetpos := COMMAND_FILE_TARGET;
         
         wait until rising_edge(clk);
     
         while (not endfile(infile)) loop
            
            read(infile, next_vector, actual_len);  
             
            read_byte := CONV_STD_LOGIC_VECTOR(bit'pos(next_vector(0)), 8);
            
            --report "read_byte=" & integer'image(to_integer(unsigned(read_byte)));
            
            data(targetpos) := to_integer(unsigned(read_byte));
            targetpos       := targetpos + 1;
            
         end loop;
         
         maskAddr         <= std_logic_vector(to_unsigned(targetpos - 1, 24));

         romtype <= std_logic_vector(to_unsigned(data(targetpos - 6), 8));
         ramtype <= std_logic_vector(to_unsigned(data(targetpos - 5), 8));
         if (data(targetpos - 3) = 1) then hasRTC  <= '1'; else hasRTC  <= '0'; end if;
         if (data(targetpos - 9) = 1) then isColor <= '1'; else isColor <= '0'; end if;
         
         wait until rising_edge(clk);
      
         file_close(infile);
      
         COMMAND_FILE_ACK_1 <= '1';
      
      end if;

   
   
   end process;
   
end architecture;


