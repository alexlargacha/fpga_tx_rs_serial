----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/31/2017 05:01:25 PM
-- Design Name:
-- Module Name: wbm_dgen1 - dataflow
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wbm_dgen is
  Generic (
      constant tp : time := 10 ns;
      constant trst : time := 320 ns;
      constant tclk : time := 100 ns
      );
    Port ( rst_o : out STD_LOGIC;
           clk_o : out STD_LOGIC;
           dat_o : out STD_LOGIC_VECTOR (7 downto 0);
           we_o : out STD_LOGIC;
           stb_o : out STD_LOGIC;
           ack_i : in STD_LOGIC;
		   TxRdy : in STD_LOGIC);
end wbm_dgen;

architecture dataflow of wbm_dgen is

signal clk_i : std_logic := '0';
signal rst_i : std_logic := '0';
signal dat_i : std_logic_vector (7 downto 0);
signal TxRdy_a : std_logic := '1';
signal stb_o_s : std_logic := '0';

begin

  -- Reset
  process
  begin
      rst_i <= '1';
      wait for trst;
      rst_i <= '0';
      wait;
  end process; --process rst

  -- CLK
  process
  begin
      while true loop
          clk_i <= '0';
          wait for tclk/2;
          clk_i <= '1';
          wait for tclk/2;
      end loop; --while
  end process; --process
  
  rst_o <= rst_i;
  clk_o <= clk_i;
  
  
  process (clk_i, rst_i, ack_i, TxRdy)
    begin
        if rst_i = '1'  then
            TxRdy_a <= '0';
        else
			if TxRdy = '1' then
				TxRdy_a <= '1';
			elsif ack_i = '1' then
				TxRdy_a <= '0';
			end if;
		end if;
    end process;

 
 stb_o_s <= TxRdy_a after tp;
 we_o <= TxRdy_a after tp;
 
 stb_o <= stb_o_s;
  
  process (stb_o_s)
  type BinFile is file of character;
  file input_file : BinFile open READ_MODE is "input_file.txt";
  variable caract : character; -- read variable
  begin
      if (rising_edge(stb_o_s)) then -- New data is sent on the rising edge
          if endfile(input_file) then
              FILE_CLOSE(input_file);
              report "Input file read finished"
              severity ERROR;
          else
              read(input_file,caract);
              dat_i <= CONV_STD_LOGIC_VECTOR(character'POS(caract),8);
          end if;
      end if;
  end process;
  
	
	
  
  with TxRdy_a select
      dat_o <= dat_i after tp when '1',
             (others => 'Z') when others;
 

end dataflow;
