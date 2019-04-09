----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/31/2017 05:54:54 PM
-- Design Name: 
-- Module Name: wbm_dmon1 - dataflow
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wbm_dmonp is
    Generic (
            constant tp : time := 10 ns;
			constant trst : time := 320 ns;
			constant tclk : time := 100 ns
            );  
    Port ( rst_o : out STD_LOGIC;
           clk_o : out STD_LOGIC;
           dat_i : in STD_LOGIC_VECTOR (7 downto 0);
           we_o : out STD_LOGIC;
           stb_o : out STD_LOGIC;
           ack_i : in STD_LOGIC;
		   RxRdy : in STD_LOGIC;
		   error_i : in STD_LOGIC);
end wbm_dmonp;

architecture dataflow of wbm_dmonp is

signal clk_i : std_logic := '0';
signal rst_i : std_logic := '0';
signal stb_o_s : std_logic := '0';
signal we_o_s : std_logic := '0';

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
    
    
    stb_o <= RxRdy after tp;
    we_o <= not RxRdy after tp;

	process (clk_i, ack_i, rst_i)
	type BinFile is file OF CHARACTER;
	file fich_sal : BinFile open WRITE_MODE is "fichero_dmon.txt";
	variable caract : CHARACTER; -- Variable de escritura
    begin
        if (rising_edge(clk_i)) then -- flanco de subida
            if rst_i = '0' then
				if ack_i = '1' then
					if error_i = '0' then
						caract := CHARACTER'VAL(conv_integer(dat_i));
						write(fich_sal,caract);
					end if;
				end if;
            end if;
        end if;
    end process;

end dataflow;
