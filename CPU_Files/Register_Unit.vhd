--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    Register_Unit.vhd
-- ARCH:    behavioral
-- DESC.:   Register file.
--*****************************************************************

library IEEE ;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_Unit is 
GENERIC (
    BIT_DEPTH       : INTEGER := 8; -- number of bits in each register
    LOG_PORT_DEPTH  : INTEGER := 3  -- binary digits of register count; reg. count is 2^LOG_PORT_DEPTH
);
PORT (
    clk_n           : IN    STD_LOGIC;                                   -- Clock, falling edge triggered
    we              : IN    STD_LOGIC;                                   -- Write enable
    ADDR1, ADDR2    : IN    STD_LOGIC_VECTOR(LOG_PORT_DEPTH-1 downto 0); -- Read addresses
    ADDR3           : IN    STD_LOGIC_VECTOR(LOG_PORT_DEPTH-1 downto 0); -- Write address
    wd              : IN    STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);      -- Write data
    RD1, RD2        : OUT   STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0)       -- Read data
);
end Register_Unit;

architecture behavioral of Register_Unit is 
    -- instantiate the actual registers for data storage
    type reg_array is array((2**LOG_PORT_DEPTH)-1 downto 0) of STD_LOGIC_VECTOR(BIT_DEPTH-1 downto 0);
    signal reg_sig : reg_array := (others => (others => '0'));
begin
    process (clk_n) is begin
        if falling_edge(clk_n) and we = '1' and not(to_integer(unsigned(ADDR3)) = 0) then
            -- write registers if write is enabled and the target address =/= R0
            reg_sig(to_integer(unsigned(ADDR3))) <= wd;
        else
            -- hold values in registers
            reg_sig <= reg_sig;
        end if;
    end process;
    -- read registers
    RD1 <= reg_sig(to_integer(unsigned(ADDR1)));
    RD2 <= reg_sig(to_integer(unsigned(ADDR2)));
end behavioral;