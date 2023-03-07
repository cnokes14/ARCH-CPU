--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    Control_Unit.vhd
-- ARCH:    Behavioral
-- DESC.:   Takes operation and splits it into various other bits
--          for use elsewhere; asynchronous. Individual outputs are
--          expained here, and overall outputs are explained further
--          in OPCode documentation.
--*****************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit is
PORT(
    OP : IN STD_LOGIC_VECTOR(6 downto 0);               -- Top 7 bits of the instruction.
    WRITE_TO_MEM : OUT STD_LOGIC_VECTOR(1 downto 0);    -- Deterines how, if at all, to write to memory.
    WRITE_TO_REG : OUT STD_LOGIC_VECTOR(1 downto 0);    -- Determines how, if at all, to write to a reg.
    BRANCH : OUT STD_LOGIC_VECTOR(1 downto 0);          -- Determines the branch case, if any.
    IMMEDIATE : OUT STD_LOGIC;                          -- 1 if the statement uses an immediate, else 0.
    UPDATE_FLAGS : OUT STD_LOGIC;                       -- 1 if N and Z flags should update from ALU.
    ALU_FUNCTION : OUT STD_LOGIC_VECTOR(5 downto 0)     -- 6 bit function determining ALU mux selection.
);
end Control_Unit;

architecture Behavioral of Control_Unit is
    begin
        process (OP) is begin
            -- if not one of the STORE operations, block out memory writing
            if OP(6 downto 3) = "1100" then WRITE_TO_MEM <= OP(1 downto 0);
            else WRITE_TO_MEM <= "00";
            end if;
        end process;
        
        process (OP) is begin
            -- if a special write, write to a register
            if OP(6 downto 3) = "1101" then
                WRITE_TO_REG <= OP(2 downto 1);
            -- if a branch or a store, write to nothing
            elsif (OP(6 downto 3) = "1100") or (OP(6 downto 4) = "100" and OP(1) = '1') then
                WRITE_TO_REG <= "00";
            -- default to writing to a branch
            else WRITE_TO_REG <= "11";
            end if;
        end process;
        
        process (OP) is begin
            -- if not a branch, clear the branch.
            if OP(6 downto 4) = "100" then BRANCH <= OP(3 downto 2);
            else BRANCH <= "00";
            end if;
        end process;
        
        process (OP) is begin            
            -- LOGICAL and ARITHMETIC OPERATIONS
            if (OP(6) = '0') then
                IMMEDIATE <= NOT OP(3);
                UPDATE_FLAGS <= NOT OP(5);
                ALU_FUNCTION <= NOT OP(4) & "00" & OP(2 downto 0);
            -- BRANCHES AND MEMORY MANAGEMENT OPERATIONS
            else
                -- handle branches
                if OP(6 downto 4) = "100" then IMMEDIATE <= NOT OP(0);
                elsif OP(6 downto 4) = "110" and (not OP(2 downto 1) = "10" or not OP(2 downto 1) = "01") then
                     IMMEDIATE <= '1';
                else IMMEDIATE <= '0';
                end if;
                -- no updates if not arithmetic
                UPDATE_FLAGS <= '0';
                -- default to addition
                ALU_FUNCTION <= "000011";
            end if;
        end process;
end Behavioral;