--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    invertN.vhd
-- ARCH:    behavioral
-- DESC.:   Given value A, multiply by -1.
--*****************************************************************

library IEEE ;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity invertN is
GENERIC (
    DATA_SIZE : INTEGER := 32
);
PORT(
    A : IN std_logic_vector (DATA_SIZE-1 downto 0);
    Y : OUT std_logic_vector (DATA_SIZE-1 downto 0)
    );
end invertN;

