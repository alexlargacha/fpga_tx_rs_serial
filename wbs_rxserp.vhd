----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.10.2017 17:29:18
-- Design Name: 
-- Module Name: rxser - Behavioral
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

entity wbs_rxserp is
	Generic (
		constant nvt: integer := 10
        ); 
    Port ( rst_i : in STD_LOGIC;
           clk_i : in STD_LOGIC;
           rx : in STD_LOGIC;
           RxRdy : out STD_LOGIC;
           ack_o : out std_logic;
           we_i : in std_logic;
           stb_i : in std_logic;
           dat_o : out STD_LOGIC_VECTOR (7 downto 0);
		   error_o : out std_logic);
end wbs_rxserp;

architecture Behavioral of wbs_rxserp is
type ctrl_state is (sby, sta0, sta1, b00, b01, b10, b11, b20, b21, b30, b31, b40, b41, b50, b51, b60, b61, b70, b71, bp0, bp1, sto, srd); 
signal act_ctrl_rxser : ctrl_state := sby;
signal next_ctrl_rxser: ctrl_state;
signal ld : std_logic := '0';
signal en : std_logic := '0';
signal ini : std_logic := '0';
signal d : std_logic := '0';
signal tc : std_logic := '0';

signal cnt : integer range  0 to nvt;

SIGNAL ff :std_logic_vector(7 downto 0 ):=(others=> '0');

signal parity_en : std_logic := '0';
signal parity_bit : std_logic := '0';

begin

--CTRL2
	process (clk_i)
	begin 
		if (rising_edge(clk_i)) then
			if rst_i = '1' then
				act_ctrl_rxser <= sby;
			else
				act_ctrl_rxser <= next_ctrl_rxser;
			end if;
		end if;
	end process;
	
	process(act_ctrl_rxser, tc, rx, stb_i)
	begin
		case act_ctrl_rxser is
			when sby =>
				if rx ='0' then
					next_ctrl_rxser <= sta0;
			 	else
					next_ctrl_rxser <= sby;
				end if;
 			when sta0 =>
				if tc ='1' then
					next_ctrl_rxser <= sta1;
			 	else
					next_ctrl_rxser <= sta0;
				end if;
			when sta1 =>
				if tc ='1' then
					next_ctrl_rxser <= b00;
			 	else
					next_ctrl_rxser <= sta1;
				end if;
			when b00 =>
				if tc ='1' then
					next_ctrl_rxser <= b01;
				else
					next_ctrl_rxser <= b00;
				end if;
			when b01 =>
				if tc ='1' then
					next_ctrl_rxser <= b10;
				else
					next_ctrl_rxser <= b01;
				end if;
		  	when b10 =>
				if tc ='1' then
					next_ctrl_rxser <= b11;
				else
					next_ctrl_rxser <= b10;
				end if;
			when b11 =>
				if tc ='1' then
					next_ctrl_rxser <= b20;
				else
					next_ctrl_rxser <= b11;
				end if;
			when b20 =>
				if tc ='1' then
					next_ctrl_rxser <= b21;
				else
					next_ctrl_rxser <= b20;
				end if;
			when b21 =>
				if tc ='1' then
					next_ctrl_rxser <= b30;
				else
					next_ctrl_rxser <= b21;
				end if;
			when b30 =>
				if tc ='1' then
					next_ctrl_rxser <= b31;
				else
					next_ctrl_rxser <= b30;
				end if;
			when b31 =>
				if tc ='1' then
					next_ctrl_rxser <= b40;
				else
					next_ctrl_rxser <= b31;
				end if;					
			when b40 =>
				if tc ='1' then
					next_ctrl_rxser <= b41;
				else
					next_ctrl_rxser <= b40;
				end if;
			when b41 =>
				if tc ='1' then
					next_ctrl_rxser <= b50;
				else
					next_ctrl_rxser <= b41;
				end if;
			when b50 =>
				if tc ='1' then
					next_ctrl_rxser <= b51;
				else
					next_ctrl_rxser <= b50;
				end if;
			when b51 =>
				if tc ='1' then
					next_ctrl_rxser <= b60;
				else
					next_ctrl_rxser <= b51;
				end if;				
			when b60 =>
				if tc ='1' then
					next_ctrl_rxser <= b61;
				else
					next_ctrl_rxser <= b60;
				end if;
			when b61 =>
				if tc ='1' then
					next_ctrl_rxser <= b70;
				else
					next_ctrl_rxser <= b61;
				end if;				
			when b70 =>
				if tc ='1' then
					next_ctrl_rxser <= b71;
				else
					next_ctrl_rxser <= b70;
				end if;
			when b71 =>
				if tc ='1' then
					next_ctrl_rxser <= bp0;
				else
					next_ctrl_rxser <= b71;
				end if;
			when bp0 =>
				if tc ='1' then
					next_ctrl_rxser <= bp1;
				else
					next_ctrl_rxser <= bp0;
				end if;
			when bp1 =>
				if tc ='1' then
					next_ctrl_rxser <= sto;
				else
					next_ctrl_rxser <= bp1;
				end if;	
			when sto =>
				if tc ='1' then
					next_ctrl_rxser <= srd;
				else
					next_ctrl_rxser <= sto;
				end if;
			when srd =>
				if rx = '0' then
					next_ctrl_rxser <= sta0;
				elsif stb_i = '1' then
					next_ctrl_rxser <= sby;
				else
					next_ctrl_rxser <= srd;
				end if;
				
	  	end case;
	end process;

	d <= rx;
	
	with act_ctrl_rxser select -- Asignación de salida ld
		ld <= '1' when sby,
			  '0' when others;
			  
	with act_ctrl_rxser select -- Asignación de salida en
		en <= tc when b00 | b10 | b20 | b30 | b40 | b50 | b60 | b70,
			  '0' when others;
	
	with act_ctrl_rxser select -- Asignación de salida ini
		ini <= '1' when sby | srd,
			  '0' when others;
			  
	with act_ctrl_rxser select -- Asignación de salida RxRdy
		RxRdy <= '1' when srd,
			  '0' when others;
	
	with act_ctrl_rxser select -- Asignación del enable para almacenar la paridad
		parity_en <= '1' when bp0,
					 '0' when others;			  
			  
--WAITD
              
process (clk_i)
  begin
      if (rising_edge(clk_i)) then -- Todo síncrono
          if ini = '1' then -- Reset
              cnt <= 0;
          else
              if cnt = nvt/2 then
                  cnt <= 0;
              else
                  cnt <= cnt + 1;
              end if;
          end if;
      end if;
  end process;
  
  process (cnt)
  begin
      if cnt = nvt/2  then
          tc <= '1';
      else
          tc <= '0';
      end if;
  end process;			  

  --REGSERPAR
  process (clk_i)
  begin
    if (rising_edge(clk_i)) then -- flanco de subida
        if (en = '1') then -- enable
            ff <= d & ff(7 downto 1); -- desplazamiento a la derecha
        end if;
    end if;
  end process;

  --parity bit store
  process (clk_i)
  begin
    if (rising_edge(clk_i)) then -- flanco de subida
        if (parity_en = '1') then -- enable
			parity_bit <= rx;
		end if;
	end if;
  end process;

	error_o <= (parity_bit xor ff(7) xor ff(6) xor ff(5) xor ff(4) xor ff(3) xor ff(2) xor ff(1) xor ff(0)) when (stb_i='1' and we_i = '0') else
             '0';

    dat_o <= ff when (stb_i='1' and we_i = '0') else
             (others => 'Z');
-- Wishbone acknoledge
    ack_o <= '1' when (stb_i='1' and we_i = '0') else
             '0';

end Behavioral;
