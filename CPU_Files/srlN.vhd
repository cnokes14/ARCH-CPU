--*****************************************************************
-- Company : Rochester Institute of Technology ( RIT )
-- Engineer : Christopher Nokes / crn2267@rit.edu
--
-- Create Date : 1/24/23
-- Design Name : srlN
-- Module Name : srlN - behavioral
-- Project Name : Lab 1
-- Target Devices : Basys3
--
-- Description : N - bit logical right shift ( SRL ) unit
--*****************************************************************
-- NOTE: This unit was written in-lab for an unrelated project
--       and is not originally from the CPU project.
--*****************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity srlN is
	GENERIC ( N : INTEGER := 4); -- bit width
	PORT ( A : IN std_logic_vector (N-1 downto 0) ;
	       SHIFT_AMT : IN std_logic_vector (N-1 downto 0) ;
	       Y : OUT std_logic_vector (N-1 downto 0)
	);
end srlN;

architecture behavioral of srlN is
	-- create array of vectors to hold each of n shifters
	type shifty_array is array(N-1 downto 0) of std_logic_vector(N-1 downto 0);
	signal aSRL : shifty_array;
	
begin
	generateSRL : for i in 0 to N-1 generate
		aSRL ( i ) (N-1-i downto 0) <= A (N-1 downto i) ;
		left_fill : if i > 0 generate
			aSRL ( i ) (N-1 downto N-i) <= ( others => '0') ;
		end generate left_fill;
	end generate generateSRL;
	
	
	out_set : process (aSRL, SHIFT_AMT, A) is begin
	   if to_integer(unsigned(SHIFT_AMT)) > N-1 or to_integer(unsigned(SHIFT_AMT)) < 0 then
	       Y <= (others => '0');
	   else Y <= aSRL(to_integer(unsigned(SHIFT_AMT)));
	   end if;
    end process out_set;
end behavioral;
