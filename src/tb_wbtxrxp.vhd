----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2017 09:57:54 AM
-- Design Name: 
-- Module Name: tb_wbtxrp - Structural
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_wbtxrxp is
--  Port ( );
end tb_wbtxrxp;

architecture Structural of tb_wbtxrxp is

--components
component wbm_dgen
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
end component;

component wbs_txserp
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
end component;

component wbs_rxserp
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
end component;

component wbm_dmonp
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
end component;

--signals

signal rst_dgen : std_logic := '0'; 
signal clk_dgen : std_logic := '0';

signal rst_dmon : std_logic := '0'; 
signal clk_dmon : std_logic := '0';

signal we_o_dgen : std_logic := '0';
signal stb_o_dgen : std_logic := '0';
signal dat_dgen1 : std_logic_vector (7 downto 0) := (others => '0');

signal ack_o_txser : std_logic := '0';

signal serial_line : std_logic := '0';

signal ack_o_rx : std_logic := '0';

signal we_o_dmon : std_logic := '0';
signal stb_o_dmon : std_logic := '0';
signal dat_o_rx : std_logic_vector (7 downto 0) := (others => '0');

signal TxRdy_s : std_logic := '0';
signal RxRdy_s : std_logic := '0';

signal error_s : std_logic := '0';

begin

instance_wbm_dgen: wbm_dgen
    generic map (
        tp => 10 ns,
        trst => 320 ns,
        tclk => 100 ns)
    port map (
        rst_o =>rst_dgen,
        clk_o =>clk_dgen,
        dat_o => dat_dgen1, 
        we_o =>we_o_dgen,
        stb_o =>stb_o_dgen,
        ack_i =>ack_o_txser,
		TxRdy => TxRdy_s
        );

instance_wbs_txserp: wbs_txserp
    generic map (
        nvt => 21
    )
    port map (
        rst_i =>rst_dgen,
        clk_i =>clk_dgen,
        dat_i =>dat_dgen1,
        we_i =>we_o_dgen,
        stb_i =>stb_o_dgen,
        ack_o =>ack_o_txser,
		TxRdy => TxRdy_s,
        tx => serial_line
    );
    
instance_wbs_rxserp: wbs_rxserp
    generic map (
        nvt => 21
    )
    port map (
        rst_i =>rst_dmon,
        clk_i =>clk_dmon,
        rx =>serial_line,
        RxRdy =>RxRdy_s,
        ack_o =>ack_o_rx,
        we_i =>we_o_dmon,
        stb_i =>stb_o_dmon,
        dat_o =>dat_o_rx,
		error_o => error_s
    );
    
instance_wbm_dmonp: wbm_dmonp
    generic map (
        tp => 10 ns,
        trst => 320 ns,
        tclk => 100 ns)
    port map (
        rst_o =>rst_dmon,
        clk_o =>clk_dmon,
        dat_i =>dat_o_rx,
        we_o =>we_o_dmon,
        stb_o =>stb_o_dmon,
        ack_i =>ack_o_rx,
        RxRdy =>RxRdy_s,
		error_i => error_s
    );


end Structural;
