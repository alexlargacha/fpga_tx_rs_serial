----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.10.2017 17:23:01
-- Design Name: 
-- Module Name: txser - Behavioral
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

entity wbs_txserp is
	Generic (
		constant nvt: integer := 10
        ); 
    Port ( rst_i : in STD_LOGIC;
           clk_i : in STD_LOGIC;
           dat_i : in STD_LOGIC_VECTOR (7 downto 0);
           we_i : in std_logic;
           stb_i : in STD_LOGIC;
           ack_o : out STD_LOGIC;
		   TxRdy : out STD_LOGIC;
           tx : out STD_LOGIC);
end wbs_txserp;

architecture Behavioral of wbs_txserp is

type ctrl_state is (sby, sta, b0, b1, b2, b3, b4, b5, b6, b7, bp, sto); --bp bit paridad
signal act_ctrl : ctrl_state := sby;
signal next_ctrl: ctrl_state;
signal ld : std_logic := '0';
signal en : std_logic := '0';
signal ini : std_logic := '0';

signal tc : std_logic := '0';

signal cnt : integer range  0 to nvt;

signal ff : std_logic_vector(7 downto 0 ):=(others=> '0');
signal m : std_logic := '0';
signal parity : std_logic := '0';

begin

-- CTRL
	process (clk_i)
	begin 
		if (rising_edge(clk_i)) then
			if rst_i = '1' then
				act_ctrl <= sby;
			else
				act_ctrl <= next_ctrl;
			end if;
		end if;
	end process;
	
	process(act_ctrl, tc, stb_i, we_i)
	begin
		case act_ctrl is
			when sby =>
				if stb_i = '1' and we_i = '1' then
					next_ctrl <= sta;
			 	else
					next_ctrl <= sby;
				end if;
 			when sta =>
				if tc ='1' then
					next_ctrl <= b0;
			 	else
					next_ctrl <= sta;
				end if;
			when b0 =>
				if tc ='1' then
					next_ctrl <= b1;
				else
					next_ctrl <= b0;
				end if;
		  	when b1 =>
				if tc ='1' then
					next_ctrl <= b2;
				else
					next_ctrl <= b1;
				end if;
			when b2 =>
				if tc ='1' then
					next_ctrl <= b3;
				else
					next_ctrl <= b2;
				end if;					
			when b3 =>
				if tc ='1' then
					next_ctrl <= b4;
				else
					next_ctrl <= b3;
				end if;					
			when b4 =>
				if tc ='1' then
					next_ctrl <= b5;
				else
					next_ctrl <= b4;
				end if;					
			when b5 =>
				if tc ='1' then
					next_ctrl <= b6;
				else
					next_ctrl <= b5;
				end if;					
			when b6 =>
				if tc ='1' then
					next_ctrl <= b7;
				else
					next_ctrl <= b6;
				end if;
			when b7 =>
				if tc ='1' then
					next_ctrl <= bp;
				else
					next_ctrl <= b7;
				end if;
			when bp =>
				if tc ='1' then
					next_ctrl <= sto;
				else
					next_ctrl <= bp;
				end if;
			when sto =>
				if tc ='1' then
					next_ctrl <= sby;
				else
					next_ctrl <= sto;
				end if;
	  	end case;
	end process;
	
	
	with act_ctrl select -- Asignación de salida tx- Mealy
		tx <= '0' when sta,
			  m   when b0 | b1 | b2 | b3 | b4 | b5 | b6 | b7,
			  parity when bp,
			  '1' when others;
	
	with act_ctrl select -- Asignación de salida ld
		ld <= '1' when sby,
			  '0' when others;
			  
	with act_ctrl select -- Asignación de salida en
		en <= '0' when sby | sta | b7 | sto,
			  tc when others;
	
	with act_ctrl select -- Asignación de salida ini
		ini <= '1' when sby,
			  '0' when others;
	
	-- Asignación de salida TxRdy
	process (clk_i, rst_i, act_ctrl)
	begin
		if rst_i = '1' then
			TxRdy <= '0';
		elsif (rising_edge(clk_i)) then
			if act_ctrl = sby then
				TxRdy <= '1';
			else
				TxRdy <= '0';
			end if;
		end if;
	end process;
			  
--WAITD

	process (clk_i)
    begin
        if (rising_edge(clk_i)) then -- Todo síncrono
            if ini = '1' then -- Reset
                cnt <= 0;
            else
                if cnt = nvt then
                    cnt <= 0;
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;
	
	process (cnt)
	begin
		if cnt = nvt then
			tc <= '1';
		else
			tc <= '0';
		end if;
	end process;
	
--REGPARSER
	process (clk_i)
	begin
	if (rising_edge(clk_i)) then -- flanco de subida
		if (stb_i = '1') then -- Load
			ff <= dat_i;
		elsif (en = '1') then -- enable
			ff <= '0' & ff(7 downto 1); -- desplazamiento a la derecha
		end if;
	end if;
	end process;

	m <= ff(0);
	
--PARITY
	process (clk_i)
	begin
	if (rising_edge(clk_i)) then -- flanco de subida
		if (stb_i = '1') then -- Load
			parity <= dat_i(7) xor dat_i(6) xor dat_i(5) xor dat_i(4) xor dat_i(3) xor dat_i(2) xor dat_i(1) xor dat_i(0);
		end if;
	end if;
	end process;
	
	-- Wishbone acknoledge
    ack_o <= '1' when (stb_i='1' and we_i = '1') else
             '0';

end Behavioral;
