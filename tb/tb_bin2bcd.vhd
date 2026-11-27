-- a simple VHDL template file
-- www.aztech.co.il - Amos Zaslavsky
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all ;        


entity tb_bin2bcd is   
end tb_bin2bcd ;


architecture arc_tb_bin2bcd of tb_bin2bcd is


component bin2bcd is
    port (resetN: in  std_logic ;
          clk   : in  std_logic;
          start:in std_logic;
          din :in std_logic_vector(7 downto 0) ;                 
          dout_low  : out std_logic_vector(3 downto  0);
          dout_mid : out std_logic_vector(3 downto  0);
          dout_high : out std_logic_vector(3 downto  0);
          ready     : out std_logic 
          
          
                                                  );
                   
end component ;

 
 
         signal resetN:std_logic ;
         signal clk   : std_logic;
         signal start :  std_logic;
         signal din   : std_logic_vector(7 downto 0) ;                 
         signal dout_low  :std_logic_vector(3 downto  0);
         signal dout_mid :std_logic_vector(3 downto  0);
         signal dout_high :std_logic_vector(3 downto  0);
         signal ready     :std_logic;
  
  
  
 begin 
 eut : bin2bcd port map(resetN,clk,start,din,dout_low,dout_mid,dout_high,ready);
 
 resetN <= '0' , '1' after 100 ns ;
 
 process 
 begin 
    clk <= '0' ; wait for 50 ns;
    clk <= '1' ; wait for 50 ns;
 end process;
 
 process 
 begin 
 
 start <='0';  din<="00000011"; 
 wait for 100 ns;
 
 start <= '1'; din<="00010001";
 wait for 100 ns ;
start <='0'; 
 wait for 1900 ns;
 
   assert false report "end of test" severity note;
   wait;
 end process;
end arc_tb_bin2bcd;