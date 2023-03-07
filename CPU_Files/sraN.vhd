--*****************************************************************
-- Company : Rochester Institute of Technology ( RIT )
-- Engineer : Christopher Nokes / crn2267@rit.edu
--
-- Create Date : 1/24/23
-- Design Name : sraN
-- Module Name : sraN - behavioral
-- Project Name : Lab 1
-- Target Devices : Basys3
--
-- Description : N - bit arithmetic right shift ( SRA ) unit
--*****************************************************************
-- NOTE: This unit was written in-lab for an unrelated project
--       and is not originally from the CPU project.
--*****************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sraN is
	GENERIC ( N : INTEGER := 4; -- bit width
		      M : INTEGER := 2); -- shift bits
	PORT ( A : IN std_logic_vector (N - 1 downto 0) ;
	       SHIFT_AMT : IN std_logic_vector (M - 1 downto 0) ;
	       Y : OUT std_logic_vector (N - 1 downto 0)
	);
end sraN;

architecture behavioral of sraN is
	-- create array of vectors to hold each of n shifters
	type shifty_array is array(N-1 downto 0) of std_logic_vector(N-1 downto 0);
	signal aSRA : shifty_array;
	
begin
	generateSRL : for i in 0 to N-1 generate
		aSRA ( i ) (N-1-i downto 0) <= A (N-1 downto i) ;
		left_fill : if i > 0 generate
			aSRA ( i ) (N-1 downto N-i) <= ( others => A(N-1)) ;
		end generate left_fill;
	end generate generateSRL;
	Y <= aSRA ( to_integer ( unsigned ( SHIFT_AMT ) ) ) when
		      ( to_integer ( unsigned ( SHIFT_AMT ) ) < N) else ( others => A(N-1));
end behavioral;