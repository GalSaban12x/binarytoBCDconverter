-- a simple VHDL template file
-- www.aztech.co.il - Amos Zaslavsky
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all ;        

entity bindown is
    port (resetN: in  std_logic ;
          clk   : in  std_logic;
          sload:in std_logic;
          bin :in std_logic_vector(7 downto 0) ;                 
          count_enable  : out std_logic    
                                                  );
                   
end bindown ;

architecture arc_bindown of bindown is
 signal count : std_logic_vector(7 downto 0);
begin
  
 
  process(clk,resetN)
  begin
      if resetN='0' then
          count <="00000000";
      elsif rising_edge(clk) then
         if sload='1' then
             count<=bin;
         
         elsif count>0  then
             count<=count-1;
         
         end if;                
      end if;  
  end process; 
  count_enable<= '0' when (count="00000000" )
        else '1';
  
    
end arc_bindown;