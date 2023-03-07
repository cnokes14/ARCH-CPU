--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    Arch.vhd
-- ARCH:    Behavioral
-- DESC.:   Overarching CPU architecture; handles interconnectivity
--          between the various subunits (memory, counter, condition,
--          ALU, control, and registers). Instructions are written
--          by disabling the counter and force-writing to memory.
--          (Presumably an actual CPU wouldn't work like this, but
--          this serves as a functioning placeholder for testing
--          and prototyping.)
--*****************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Arch is
GENERIC (   REGISTER_WIDTH : INTEGER := 32;
            MEMORY_WIDTH   : INTEGER := 11;
            LOG_REGISTER_COUNT : INTEGER := 4
            );
PORT(
    CLK : IN STD_LOGIC;
    FORCE_MEMORY_WRITE_ENABLE : IN STD_LOGIC_VECTOR(1 downto 0);
    FORCE_MEMORY_WRITE_ADDRESS : IN STD_LOGIC_VECTOR(MEMORY_WIDTH-1 downto 0);
    FORCE_MEMORY_WRITE_DATA : IN STD_LOGIC_VECTOR(REGISTER_WIDTH-1 downto 0);
    FORCE_COUNTER_DISABLE : IN STD_LOGIC
);
end Arch;

architecture Behavioral of Arch is
    -- Output of the COUNTER_UNIT. Merges with 0s to form instruction read signal.
    signal COUNTER_UNIT_OUTPUT                  : STD_LOGIC_VECTOR(7 downto 0);
    -- Memory write enable; 00-No Write, 01-Byte Write, 10-Halfword Write, 11-Word Write
    signal MEMORY_WRITE_ENABLE                  : STD_LOGIC_VECTOR(1 downto 0);
    -- Data read from memory at ALU OUTPUT 15->0
    signal MEMORY_READ_DATA                     : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 downto 0);
    -- Data read from memory at "00" & COUNTER_UNIT_OUTPUT & "00"
    signal INSTRUCTION_DATA                     : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 downto 0);
    -- On a 1, COUNTER_UNIT sets its counter to BRANCH input instead of the next increment.
    signal BRANCH_CONDITION                     : STD_LOGIC;
    -- Sent from Control to the Condition_Unit; 
    -- 00:No Branch, 01:Branch on ALU Negative, 10:Branch on ALU 0, 11: Branch unconditional
    signal BRANCH_CONDITION_VECTOR              : STD_LOGIC_VECTOR(1 downto 0);
    -- Output of the ALU unit
    signal ALU_OUTPUT                           : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 downto 0);
    -- ALU write source; 00: all 0s (unused), 01: MEMORY, 10: Program Counter, 11: ALU
    signal REGISTER_WRITE                       : STD_LOGIC_VECTOR(1 downto 0);
    -- Whether or not to write to a register; set when one of the REGISTER_WRITE values is set.
    signal REGISTER_WRITE_ENABLE                : STD_LOGIC;
    -- Whether or not the current instruction is an immediate.
    signal IS_IMMEDIATE                         : STD_LOGIC;
    -- Based on IS_IMMEDIATE, this value is set for ADDR3
    signal IMMEDIATE_SELECT_ADDR3_OUTPUT        : STD_LOGIC_VECTOR(3 downto 0);
    -- Data to be written to a register, determined by MUX with select REGISTER_WRITE
    signal REGISTER_WRITE_DATA_SELECT_OUTPUT    : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 downto 0);
    -- Value read from ADDR1, ADDR2 of the REGISTER_UNIT
    signal REGISTER_READ_1, REGISTER_READ_2     : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 downto 0);
    -- VALUE SELECTED BETWEEN IMMEDIATE AND ADDR2 VAL FOR USE IN THE ALU
    signal ALU_INPUT_B_SELECT_OUTPUT            : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 downto 0);
    -- FUNCTION SENT TO THE ALU FROM THE CONTROL UNIT
    signal ALU_FUNCTION                         : STD_LOGIC_VECTOR(5 downto 0);
    -- SET TO UPDATE CONDITION_UNIT FLAGS WITH CURRENT ALU VALUE ON FALLING EDGE.
    signal UPDATE_FLAGS                         : STD_LOGIC;
    -- SET TO MEMORY ADDRESS, EITHER BY FORCE OR BY REGISTER
    signal MEMORY_ADDRESS_INCLUDE_FORCE         : STD_LOGIC_VECTOR(MEMORY_WIDTH-1 downto 0);
    -- SET TO MEMORY WRITE DATA, EITHER BY FORCE OR BY ALU
    signal MEMORY_DATA_INCLUDE_FORCE            : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 downto 0);
    -- SET MEMORY WRITING STATUS, EITHER BY FORCE OR BY CONTROL UNIT
    signal MEMORY_WRITE_ENABLE_INCLUDE_FORCE    : STD_LOGIC_VECTOR(1 downto 0);

    begin
        -- DEFINE MEMORY UNIT ENTITY
        memory : entity work.Memory_Unit
            generic map(width => MEMORY_WIDTH, 
                        size => REGISTER_WIDTH)
            port map(CLK => CLK, 
                     ADDR => MEMORY_ADDRESS_INCLUDE_FORCE,
                     INSTRUCTION_COUNTER(9 downto 2) => COUNTER_UNIT_OUTPUT,
                     INSTRUCTION_COUNTER(10) => '0',
                     INSTRUCTION_COUNTER(1 downto 0) => "00",
                     WRITE_ENABLE => MEMORY_WRITE_ENABLE_INCLUDE_FORCE,
                     WRITE_DATA => MEMORY_DATA_INCLUDE_FORCE,
                     READ_DATA => MEMORY_READ_DATA,
                     INSTRUCTION_DATA => INSTRUCTION_DATA);
                     
        -- DEFINE COUNTER UNIT ENTITY
        counter : entity work.Counter_Unit
            generic map(counter_size => 8)
            port map(CLK => CLK, 
                     BRANCH_POSITION => ALU_OUTPUT(9 downto 2), 
                     BRANCH_CONDITION => BRANCH_CONDITION,
                     DISABLE => FORCE_COUNTER_DISABLE, 
                     COUNTER_OUT => COUNTER_UNIT_OUTPUT);
                     
        -- DEFINE REGISTER UNIT ENTITY
        registers : entity work.Register_Unit
            generic map(BIT_DEPTH => REGISTER_WIDTH, 
                        LOG_PORT_DEPTH => 4)
            port map(CLK_N => CLK,
                     WE => REGISTER_WRITE_ENABLE,
                     ADDR1 => INSTRUCTION_DATA(24 downto 21),
                     ADDR2 => INSTRUCTION_DATA(20 downto 17),
                     ADDR3 => IMMEDIATE_SELECT_ADDR3_OUTPUT,
                     WD => REGISTER_WRITE_DATA_SELECT_OUTPUT,
                     RD1 => REGISTER_READ_1,
                     RD2 => REGISTER_READ_2);
                     
        -- DEFINE CONDITION UNIT ENTITY
        condition : entity work.Condition_Unit
            generic map(width => REGISTER_WIDTH)
            port map(CLK => CLK,
                     BRANCH_CONDITION => BRANCH_CONDITION_VECTOR,
                     NUM_CHECK => ALU_OUTPUT,
                     UPDATE_FLAGS => UPDATE_FLAGS,
                     CONDITION => BRANCH_CONDITION);
                     
        -- DEFINE ALU ENTITY
        ALU : entity work.ALU
            generic map(DATA_SIZE => REGISTER_WIDTH,
                        SHIFT_DIGITS => 6)
            port map(A => REGISTER_READ_1,
                     B => ALU_INPUT_B_SELECT_OUTPUT,
                     OP => ALU_FUNCTION,
                     Y => ALU_OUTPUT);
                     
        -- DEFINE CONTROL UNIT ENTITY
        control : entity work.Control_Unit
            port map(OP => INSTRUCTION_DATA(31 downto 25),
                     WRITE_TO_MEM => MEMORY_WRITE_ENABLE,
                     WRITE_TO_REG => REGISTER_WRITE,
                     BRANCH => BRANCH_CONDITION_VECTOR,
                     IMMEDIATE => IS_IMMEDIATE,
                     UPDATE_FLAGS => UPDATE_FLAGS,
                     ALU_FUNCTION => ALU_FUNCTION);
                     
        -- SELECT REGISTER WRITE ADDRESS; ADDR2 IF IMMEDIATE, ADDR3 OTHERWISE.
        with IS_IMMEDIATE select
            IMMEDIATE_SELECT_ADDR3_OUTPUT <= INSTRUCTION_DATA(20 downto 17) when '1',
                                             INSTRUCTION_DATA(16 downto 13) when others;
                                             
        -- SELECT REGISTER WRITE SOURCE; SEE REGISTER_WRITE DECLARATION FOR DETAILS.                             
        with REGISTER_WRITE select
            REGISTER_WRITE_DATA_SELECT_OUTPUT <= ALU_OUTPUT when "11",
                                                 MEMORY_READ_DATA when "01",
                                                 x"00000" & "00" & COUNTER_UNIT_OUTPUT & "00" when "10",
                                                 (others => '0') when others;
                                                 
        -- SET REGISTER WRITE IF SOURCE IS MEMORY, COUNTER, OR ALU
        REGISTER_WRITE_ENABLE <= REGISTER_WRITE(1) OR REGISTER_WRITE(0);
        
        -- SET ALU INPUT B TO BE IMMEDIATE OR ADDR2 VALUE
        with IS_IMMEDIATE select
            ALU_INPUT_B_SELECT_OUTPUT(16 downto 0) <= INSTRUCTION_DATA(16 downto 0) when '1',
                                                      REGISTER_READ_2(16 downto 0) when others;
        with IS_IMMEDIATE select
            ALU_INPUT_B_SELECT_OUTPUT(31 downto 17) <= (others => INSTRUCTION_DATA(16)) when '1',
                                                       REGISTER_READ_2(31 downto 17) when others;
        
        -- SET MEMORY VALUES TO TAKE INPUT FROM FORCED INPUT OR FROM REGISTERS
        with FORCE_COUNTER_DISABLE select
            MEMORY_DATA_INCLUDE_FORCE <= FORCE_MEMORY_WRITE_DATA when '1',
                                         REGISTER_READ_2 when OTHERS;
        with FORCE_COUNTER_DISABLE select
            MEMORY_ADDRESS_INCLUDE_FORCE <= FORCE_MEMORY_WRITE_ADDRESS when '1',
                                            ALU_OUTPUT(10 downto 0) when OTHERS;
        with FORCE_COUNTER_DISABLE select
            MEMORY_WRITE_ENABLE_INCLUDE_FORCE <= FORCE_MEMORY_WRITE_ENABLE when '1',
                                                 MEMORY_WRITE_ENABLE when OTHERS;
        
            
end Behavioral;