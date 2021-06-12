library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;  
use STD.textio.all;

entity framebuffer is
   generic
   (
      FRAMESIZE_X : integer;
      FRAMESIZE_Y : integer
   );
   port 
   (
      clk                  : in  std_logic; 
       
      pixel_in_addr        : in  integer range 0 to 32255;
      pixel_in_data        : in  std_logic_vector(11 downto 0);  
      pixel_in_we          : in  std_logic        
   );
end entity;

architecture arch of framebuffer is

   type tPixelArray is array(0 to (FRAMESIZE_X * FRAMESIZE_Y) - 1) of std_logic_vector(11 downto 0);
   signal PixelArray : tPixelArray := (others => (others => '0'));
   
begin 

   -- fill framebuffer
   process (clk)
   begin
      if rising_edge(clk) then
         
         if (pixel_in_we = '1') then
            PixelArray(pixel_in_addr) <= pixel_in_data;
         end if;
      
      end if;
   end process;

-- synthesis translate_off
   
   goutput : if 1 = 1 generate
   begin
   
      process
      
         file outfile: text;
         variable f_status: FILE_OPEN_STATUS;
         variable line_out : line;
         variable color : unsigned(31 downto 0);
         variable linecounter_int : integer;
         
      begin
   
         file_open(f_status, outfile, "gra_fb_out.gra", write_mode);
         file_close(outfile);
         
         file_open(f_status, outfile, "gra_fb_out.gra", append_mode);
         write(line_out, string'("224#144#6")); 
         writeline(outfile, line_out);
         
         while (true) loop
            wait until ((pixel_in_addr mod 224) = (224 - 1)) and pixel_in_we = '1';
            linecounter_int := pixel_in_addr / 224;
   
            wait for 100 ns;
   
            for x in 0 to 223 loop
               color := (31 downto 12 => '0') & unsigned(PixelArray(x + linecounter_int * 224));
               color := x"00" & unsigned(color(11 downto 8)) & unsigned(color(11 downto 8)) & unsigned(color(7 downto 4)) & unsigned(color(7 downto 4)) & unsigned(color(3 downto 0)) & unsigned(color(3 downto 0));
            
               write(line_out, to_integer(color));
               write(line_out, string'("#"));
               write(line_out, x);
               write(line_out, string'("#")); 
               write(line_out, linecounter_int);
               writeline(outfile, line_out);
   
            end loop;
            
            file_close(outfile);
            file_open(f_status, outfile, "gra_fb_out.gra", append_mode);
            
         end loop;
         
      end process;
   
   end generate goutput;
   
-- synthesis translate_on

end architecture;





