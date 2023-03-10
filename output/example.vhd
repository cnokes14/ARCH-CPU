library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity example is end entity example;

architecture TB of example is
    signal CLK : STD_LOGIC := '0';
    signal FORCE_MEMORY_WRITE_ENABLE : STD_LOGIC_VECTOR(1 downto 0);
    signal FORCE_MEMORY_WRITE_ADDRESS : STD_LOGIC_VECTOR(10 downto 0);
    signal FORCE_MEMORY_WRITE_DATA : STD_LOGIC_VECTOR(31 downto 0);
    signal FORCE_COUNTER_DISABLE : STD_LOGIC := '1'; 
    signal PROGRAM_EXIT : STD_LOGIC := '0';
    
    type TEST_REC is record
        FORCE_MEMORY_WRITE_ENABLE : STD_LOGIC_VECTOR(1 downto 0);
        FORCE_MEMORY_WRITE_ADDRESS : STD_LOGIC_VECTOR(10 downto 0);
        FORCE_MEMORY_WRITE_DATA : STD_LOGIC_VECTOR(31 downto 0);
    end record TEST_REC;
    
    type TEST_REC_ARRAY is array(integer range<>) of TEST_REC;constant test : TEST_REC_ARRAY := (

-- AUTHOR: CHRISTOPHER NOKES
-- DESCRIPTION: BASIC FILE TO DEMONSTRATE INITIAL CAPABILITIES
--              OF THE CPU AND ADJACENT LANGUAGE; SUM THE FIRST 
--              10 NUMBERS FROM 210 TO 225, STORE IN MEMORY FROM ADDRESSES 
--              60 TO 120
-- R1 = 210 (VALUE)
-- R2 = 0 (TOTAL)
-- R3 = 60 (INDEX)
-- R2 = R2 + R1
-- STORE R2 AT R3
-- R3 += 4
-- NUM += 1
-- SUB 226 FROM R1
-- IF ZERO, GOTO END
-- ELSE, LOOP
("11", "00000000000", "00100110000000100000000011010010"), 	-- LINE 000 - R1 = 210
("11", "00000000100", "00100110000001000000000000000000"), 	-- LINE 004 - R2 = 0
("11", "00000001000", "00100110000001100000000000111100"), 	-- LINE 008 - R3 = 60
("11", "00000001100", "00110110010000100100000000000000"), 	-- LINE 012 - R2 = R2 + R1
("11", "00000010000", "11000110011001000000000000000000"), 	-- LINE 016 - MEM[R3] = R2
("11", "00000010100", "00100110011001100000000000000100"), 	-- LINE 020 - R3+=4
("11", "00000011000", "00100110001000100000000000000001"), 	-- LINE 024 - R1++
("11", "00000011100", "00101000001000000000000011100010"), 	-- LINE 028 - COMPARE R1 TO 226
("11", "00000100000", "10010000000000000000000000101000"), 	-- LINE 032 - BRANCH TO 40 IF 0.
("11", "00000100100", "10011000000000000000000000001100"), 	-- LINE 036 - BRANCH TO 12 FOR LOOP.
("11", "00000101000", "00100110000011000000000001100011"), 	-- LINE 040 - LOAD 99 INTO R6, SHOWING COMPLETION.
("11", "00000101100", x"FFFFFFFF"));	 -- PROGRAM EXIT COMMAND.
    begin
        dut : entity work.Arch
            port map(clk => CLK, 
                     FORCE_MEMORY_WRITE_ENABLE => FORCE_MEMORY_WRITE_ENABLE,
                     FORCE_MEMORY_WRITE_ADDRESS => FORCE_MEMORY_WRITE_ADDRESS,
                     FORCE_MEMORY_WRITE_DATA => FORCE_MEMORY_WRITE_DATA,
                     FORCE_COUNTER_DISABLE => FORCE_COUNTER_DISABLE,
                     PROGRAM_EXIT => PROGRAM_EXIT);
        CLK <= not CLK after 20 ns;
        
        stimuli : process begin
            for i in test'range loop
                FORCE_MEMORY_WRITE_ENABLE <= test(i).FORCE_MEMORY_WRITE_ENABLE;
                FORCE_MEMORY_WRITE_ADDRESS <= test(i).FORCE_MEMORY_WRITE_ADDRESS;
                FORCE_MEMORY_WRITE_DATA <= test(i).FORCE_MEMORY_WRITE_DATA;
                wait for 40 ns;
            end loop;
            wait until clk = '0';
            FORCE_COUNTER_DISABLE <= '0';
            wait;
        end process;
        
        check : process is begin
            while true loop
                assert PROGRAM_EXIT = '0' report "Program terminated." severity failure;
                wait for 1 ns;
            end loop;
        end process check;
        
end TB;
