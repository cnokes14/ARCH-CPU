--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    Memory_Unit.vhd
-- ARCH:    Behavioral
-- DESC.:   Memory unit, big endian. Holds values unless written to.
--          Memory for values and instructions are handled in the same
--          unit; handling writing and access faults will be handled by
--          parent units. 
--*****************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory_Unit is
GENERIC (   width : INTEGER := 11;  -- bits to address memory; memory has 2^width bytes
            size  : INTEGER := 32   -- size of words in the CPU; made up of n bytes
);
PORT(
    -- Clock; unit activates on rising edge.
    CLK : IN STD_LOGIC;
    -- Address being pointed to, for reading or writing.
    ADDR : IN STD_LOGIC_VECTOR(width-1 downto 0);
    -- Address of the instruction currently being read.
    INSTRUCTION_COUNTER : IN STD_LOGIC_VECTOR(width-1 downto 0);
    -- Whether or not writing to the memory unit is currently enabled;
    -- 00 is no write, 01 is byte write, 10 is halfword write, 11 is word write.
    -- Writing occurs on clock rising edge.
    WRITE_ENABLE : IN STD_LOGIC_VECTOR(1 downto 0);
    -- Data to write to memory; bytes and halfwords write lower bits when applicable
    WRITE_DATA : IN STD_LOGIC_VECTOR(size-1 downto 0);
    -- Data currently read at address ADDR.
    READ_DATA : OUT STD_LOGIC_VECTOR(size-1 downto 0);
    -- Instruction currently read at address INSTRUCTION_COUNTER.
    INSTRUCTION_DATA : OUT STD_LOGIC_VECTOR(size-1 downto 0)
);
end Memory_Unit;

architecture Behavioral of Memory_Unit is
    -- Actual memory; holds 2^width bytes, updates on rising edge if write is enabled.
    type mem_array is array((2**width)-1 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
    -- All values in memory default to 0.
    signal mem_sig : mem_array := (others => (others => '0'));
    begin
        process (clk) is begin
            -- write on rising clock edge
            if rising_edge(clk) then
                -- On a 01, write a byte to the given address.
                if WRITE_ENABLE = "01" then 
                    mem_sig(to_integer(unsigned(ADDR))) <= WRITE_DATA(7 downto 0);
                -- On a 10, write a halfword to the address and address+1
                elsif WRITE_ENABLE = "10" then
                    mem_sig(to_integer(unsigned(ADDR))) <= WRITE_DATA(15 downto 8);
                    mem_sig(to_integer(unsigned(ADDR)) + 1) <= WRITE_DATA(7 downto 0);
                -- On a 11, write a word to the address->address+3
                elsif WRITE_ENABLE = "11" then
                    mem_sig(to_integer(unsigned(ADDR))) <= WRITE_DATA(31 downto 24);
                    mem_sig(to_integer(unsigned(ADDR)) + 1) <= WRITE_DATA(23 downto 16);
                    mem_sig(to_integer(unsigned(ADDR)) + 2) <= WRITE_DATA(15 downto 8);
                    mem_sig(to_integer(unsigned(ADDR)) + 3) <= WRITE_DATA(7 downto 0);
                -- Defaults to implying values holding
                end if;
            -- memory holds values
            else mem_sig <= mem_sig;
            end if;
        end process;
    
    -- read data at given address; process exists to ensure no index out of bounds error
    process (ADDR, mem_sig) is begin
        if to_integer(unsigned(ADDR)) < (2**width)-3 then
            READ_DATA(31 downto 24) <= mem_sig(to_integer(unsigned(ADDR)));
            READ_DATA(23 downto 16) <= mem_sig(to_integer(unsigned(ADDR)) + 1);
            READ_DATA(15 downto 8) <= mem_sig(to_integer(unsigned(ADDR)) + 2);
            READ_DATA(7 downto 0) <= mem_sig(to_integer(unsigned(ADDR)) + 3);
        else READ_DATA <= (others => '0');
        end if;
    end process;
    
    -- read the instruction data
    INSTRUCTION_DATA(31 downto 24) <= mem_sig(to_integer(unsigned(INSTRUCTION_COUNTER)));
    INSTRUCTION_DATA(23 downto 16) <= mem_sig(to_integer(unsigned(INSTRUCTION_COUNTER)) + 1);
    INSTRUCTION_DATA(15 downto 8) <= mem_sig(to_integer(unsigned(INSTRUCTION_COUNTER)) + 2);
    INSTRUCTION_DATA(7 downto 0) <= mem_sig(to_integer(unsigned(INSTRUCTION_COUNTER)) + 3);
        
end Behavioral;