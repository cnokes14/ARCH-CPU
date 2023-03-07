--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    ALU.vhd
-- ARCH:    behavioral
-- DESC.:   Performs y=A-B.
--*****************************************************************

library IEEE ;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity subN is
GENERIC (
    width : INTEGER := 32
);
PORT(
    A : IN std_logic_vector (width-1 downto 0);
    B : IN std_logic_vector (width-1 downto 0);
    Y : OUT std_logic_vector (width-1 downto 0)
    );
end subN;

architecture behavioral of subN is
    signal not_B : STD_LOGIC_VECTOR(width-1 downto 0);
    begin
        not_B <= not B;
            ADDER : entity work.adder_carryN 
                generic map(width => width)
                port map(A => A, B => not_B, Cin => '1', Sum => Y);
    
end behavioral;