--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    Counter_Unit.vhd
-- ARCH:    Behavioral
-- DESC.:   Increments the current program count. When disabled,
--          does not increment; when Branch_Condition is 1, sets
--          the counter to be the Branch_Position instead of the
--          next counter on the rising clock edge. Because instructions
--          are only accessed at multiples of 4, the first two bits
--          aren't sent here; the counter starts at -1 so that on the
--          first clock tick it runs the first instruction.
--*****************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter_Unit is
GENERIC ( counter_size : INTEGER := 8);
PORT(
    CLK : IN STD_LOGIC;
    BRANCH_POSITION : IN STD_LOGIC_VECTOR(counter_size-1 downto 0);
    BRANCH_CONDITION : IN STD_LOGIC;
    DISABLE : IN STD_LOGIC;
    COUNTER_OUT : OUT STD_LOGIC_VECTOR(counter_size-1 downto 0)
);
end Counter_Unit;

architecture behavioral of Counter_Unit is
    signal COUNTER : STD_LOGIC_VECTOR(counter_size-1 downto 0) := "11111111";
    signal ADDER_OUTPUT : STD_LOGIC_VECTOR(counter_size-1 downto 0);

    begin
        process (clk) is begin
            if rising_edge(clk) and DISABLE <= '0' then
                if BRANCH_CONDITION = '1' then
                    COUNTER <= BRANCH_POSITION;
                else 
                    COUNTER <= ADDER_OUTPUT;
                end if;
            else COUNTER <= COUNTER;
            end if;
        end process;
        COUNTER_OUT <= COUNTER;
        ADDER_OUTPUT <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(UNSIGNED(COUNTER)) + 1, 8));
        
end behavioral;