library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fullAdder is port(
    A,B,C : IN STD_LOGIC;
    Sum, Cout : OUT STD_LOGIC);
end fullAdder;

architecture behavioral of fullAdder is begin
    Cout <= (A and B) or (B and C) or (A and C);
    Sum <= A xor B xor C;
end behavioral;
