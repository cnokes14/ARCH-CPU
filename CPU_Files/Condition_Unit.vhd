--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    Condition_Unit.vhd
-- ARCH:    behavioral
-- DESC.:   Unit has two FFs that update on clock rising edge:
--              - isNeg, which is set to high IFF the first digit
--                of NUM_CHECK is 1.
--              - isZero, which is set to high IFF all numbers in
--                NUM_CHECK are 0.
--          Both are set to 0 otherwise. BRANCH_CONDITION serves as
--          as a MUX select for these two which determines the
--          output, CONDITION.
--              - When B_C is 00, clear unconditionally.
--              - When B_C is 01, set value to isNeg FF.
--              - When B_C is 10, set value to isZero FF.
--              - When B_C is 11, set unconditionally.
--          All values update async besides the internal isNeg and
--          isZero signals.
--*****************************************************************

library IEEE ;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Condition_Unit is
GENERIC ( width : INTEGER := 32);
PORT(
    CLK              : IN STD_LOGIC;
    BRANCH_CONDITION : IN STD_LOGIC_VECTOR(1 downto 0);
    NUM_CHECK        : IN STD_LOGIC_VECTOR(width-1 downto 0);
    UPDATE_FLAGS     : IN STD_LOGIC;
    CONDITION        : OUT STD_LOGIC
);
end Condition_Unit;

architecture behavioral of Condition_Unit is
    signal isNeg : STD_LOGIC := '0';
    signal isZero : STD_LOGIC := '0';
    begin
        process (clk) is begin
            if falling_edge(clk) and UPDATE_FLAGS = '1' then
                isNeg <= NUM_CHECK(width-1);
                if(to_integer(unsigned(NUM_CHECK)) = 0) then isZero <= '1';
                else isZero <= '0';
                end if;
            else
                isNeg <= isNeg;
                isZero <= isZero;
            end if;
        end process;
        
        with BRANCH_CONDITION select
            CONDITION <= '0' when "00",
                         isNeg when "01",
                         isZero when "10",
                         '1' when OTHERS;
end behavioral;