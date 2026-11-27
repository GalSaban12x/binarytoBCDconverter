-- a simple VHDL template file
-- www.aztech.co.il - Amos Zaslavsky
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
--use ieee.numeric_std.all ;        

entity bcdup is
    port (resetN: in  std_logic ;
          clk   : in  std_logic;
         sclear:in std_logic;  
          cet  : in std_logic ;
          cep  : in std_logic ;
          qout : out std_logic_vector(3 downto 0);
          tc   : out std_logic
          
                                                  );
          
          
end bcdup ;

architecture arc_bcdup of bcdup is
 signal cnt : std_logic_vector(3 downto 0); 
begin
  
 qout<=cnt;
  process(clk,resetN)
  begin
      if resetN='0' then
          cnt <="0000";
      elsif rising_edge(clk) then
         if sclear='1' then
             cnt<="0000";
         elsif (cep='1' and cet='1') then 
             
               if cnt="1001" then
                 cnt<="0000";
               else 
                   cnt<=cnt+1;
               end if;
      end if;      
         end if;
              
  end process; 
  tc<= '1' when (cet='1' and cnt="1001") 
        else '0';
  
    
end arc_bcdup;