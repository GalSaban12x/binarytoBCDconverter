-- a simple VHDL template file
-- www.aztech.co.il - Amos Zaslavsky
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all ;        

entity bin2bcd is
    port (resetN: in  std_logic ;
          clk   : in  std_logic;
          start:in std_logic;
          din :in std_logic_vector(7 downto 0) ;                 
          --dout_low  : out std_logic_vector(3 downto  0);
          --dout_mid : out std_logic_vector(3 downto  0);
          --dout_high : out std_logic_vector(3 downto  0);
          ready     : out std_logic; 
          
          HEX0      : out std_logic_vector(6 downto 0); -- units
          HEX1      : out std_logic_vector(6 downto 0); -- tens
          HEX2      : out std_logic_vector(6 downto 0)  -- hundreds
          
          
                                                  );
                   
end bin2bcd ;

architecture arc_bin2bcd of bin2bcd is

component bcdup is
    port (resetN: in  std_logic ;
          clk   : in  std_logic;
         sclear:in std_logic;  
          cet  : in std_logic ;
          cep  : in std_logic ;
          qout : out std_logic_vector(3 downto 0);
          tc   : out std_logic
          
                                                  );
          
          
end  component;



component bindown is
    port (resetN: in  std_logic ;
          clk   : in  std_logic;
          sload:in std_logic;
          bin :in std_logic_vector(7 downto 0) ;                 
          count_enable  : out std_logic    
                                                  );
                   
end component ;


component hexsse is
    port (
      ena : in  std_logic;
      din : in  std_logic_vector(3 downto 0);
      ss  : out std_logic_vector(6 downto 0)
    );
  end component;


signal tc1, tc2,t3,count_enable : std_logic;

signal bcd_low, bcd_mid, bcd_high : std_logic_vector(3 downto 0);

 
begin
  
 u1 : bcdup port map(resetN,clk,start,'1',count_enable,bcd_low,tc1);
 u2 : bcdup port map(resetN,clk,start,tc1,count_enable,bcd_mid,tc2);
 u3 : bcdup
  port map(
    resetN => resetN,
    clk    => clk,
    sclear => start,
    cet    => tc2,
    cep    => count_enable,
    qout   => bcd_high,
    tc     => open
  );
 u4 : bindown port map(resetN,clk,start,din,count_enable);
 
 ready <= '0' when (count_enable='1') 
        else '1';
        
        
         
  
   h0 : hexsse port map(ena=>'1', din=>bcd_low,  ss=>HEX0);
   h1 : hexsse port map(ena=>'1', din=>bcd_mid,  ss=>HEX1);
   h2 : hexsse port map(ena=>'1', din=>bcd_high, ss=>HEX2);
    
end arc_bin2bcd;