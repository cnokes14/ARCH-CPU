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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adderN is
    generic(width : Integer := 8);
    port(A, B : IN STD_LOGIC_VECTOR(width-1 downto 0);
         Sum  : OUT STD_LOGIC_VECTOR(width-1 downto 0);
         Cout : OUT STD_LOGIC);
end adderN;

architecture Behavioral of adderN is
    signal Carry : STD_LOGIC_VECTOR(width-2 downto 0);
    component fullAdder is port(
        A, B, C : IN STD_LOGIC;
        Sum, Cout : OUT STD_LOGIC
    );
    end component;
    begin
        adder : for i in 0 to width-1 generate
            ls_bit : if i = 0 generate
                ls_cell : fullAdder port map(
                    A => A(i),
                    B => B(i),
                    C => '0',
                    Sum => Sum(i),
                    Cout => Carry(i)
                );
             end generate ls_bit;
             middle_bit : if i > 0 and i < width-1 generate
                middle_cell : fullAdder port map(
                    A => A(i),
                    B => B(i),
                    C => Carry(i-1),
                    Sum => Sum(i),
                    Cout => Carry(i)
                );
             end generate middle_bit;
             ms_bit : if i = width-1 generate
                ms_cell : fullAdder port map(
                    A => A(i),
                    B => B(i),
                    C => Carry(i-1),
                    Sum => Sum(i),
                    Cout => Cout
                );
             end generate ms_bit;
         end generate adder;
end Behavioral;
