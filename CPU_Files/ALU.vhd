--*****************************************************************
-- NAME:    Christopher Nokes
-- FILE:    ALU.vhd
-- ARCH:    behavioral
-- DESC.:   ALU, asynchronous. Basically just a MUX handler.
--*****************************************************************

library IEEE ;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
GENERIC (
    DATA_SIZE : INTEGER := 32;
    SHIFT_DIGITS : INTEGER := 6
);
PORT(
    A : IN std_logic_vector (DATA_SIZE-1 downto 0) ;
    B : IN std_logic_vector (DATA_SIZE-1 downto 0) ;
    OP : IN std_logic_vector(5 downto 0);
    Y : OUT std_logic_vector (DATA_SIZE-1 downto 0)
    );
end ALU;

architecture Behavioral of ALU is
    signal SRA_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal SRL_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal SLL_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal ADD_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal SUB_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal AND_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal OR_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal XOR_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal NAND_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal NOR_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal NOT_OUT : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    
    begin
    -- COMPONENTS FOR ARITHMETIC UNITS
    ADDER : entity work.adderN 
            generic map(width => DATA_SIZE)
            port map(A => A, B => B, Sum => ADD_OUT);
    SUBBER : entity work.subN 
             generic map(width => DATA_SIZE)
             port map(A => A, B => B, Y => SUB_OUT);
    SLL_COMP : entity work.sllN
            generic map (N => DATA_SIZE, M => SHIFT_DIGITS)
            port map ( A => A , SHIFT_AMT => B(SHIFT_DIGITS-1 downto 0), Y => SLL_OUT);    
    SRL_COMP : entity work.srlN
            generic map ( N => DATA_SIZE , M => SHIFT_DIGITS)
            port map ( A => A , SHIFT_AMT => B(SHIFT_DIGITS-1 downto 0), Y => SRL_OUT); 
    SRA_COMP : entity work.sraN
            generic map ( N => DATA_SIZE , M => SHIFT_DIGITS)
            port map ( A => A , SHIFT_AMT => B(SHIFT_DIGITS-1 downto 0), Y => SRA_OUT); 
    
    -- GATES FOR LOGIC UNITS
    AND_OUT <= A and B;
    OR_OUT <= A or B;
    XOR_OUT <= A xor B;
    NAND_OUT <= A nand B;
    NOR_OUT <= A nor B;
    NOT_OUT <= not A;
    
    
    with OP select
        Y <= SRA_OUT when "000000",
             SRL_OUT when "000001",
             SLL_OUT when "000010",
             ADD_OUT when "000011",
             SUB_OUT when "000100",
             AND_OUT when "100000",
             OR_OUT when "100001",
             XOR_OUT when "100010",
             NAND_OUT when "100011",
             NOR_OUT when "100100",
             NOT_OUT when OTHERS;
end Behavioral;