library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tt_um_spiking_nn is
    Port (
        ui_in   : in  STD_LOGIC_VECTOR (7 downto 0); -- Dedicated inputs
        uo_out  : out STD_LOGIC_VECTOR (7 downto 0); -- Dedicated outputs
        uio_in  : in  STD_LOGIC_VECTOR (7 downto 0); -- IOs: Input path
        uio_out : out STD_LOGIC_VECTOR (7 downto 0); -- IOs: Output path
        uio_oe  : out STD_LOGIC_VECTOR (7 downto 0); -- IOs: Enable path (active high)
        ena     : in  STD_LOGIC;                     -- always 1 when powered
        clk     : in  STD_LOGIC;                     -- clock
        rst_n   : in  STD_LOGIC                      -- reset_n - low to reset
    );
end tt_um_spiking_nn;

architecture Behavioral of tt_um_spiking_nn is
    signal rst : STD_LOGIC;
begin
    -- TinyTapeout uses an active-low reset (rst_n), but our logic uses active-high
    rst <= not rst_n;

    -- We must tie off the bidirectional IO pins since we aren't using them
    uio_out <= (others => '0');
    uio_oe  <= (others => '0');

    -- Instantiate the Network Controller
    net_ctrl: entity work.network_control
        port map (
            clk     => clk,
            rst     => rst,
            inputs  => ui_in,
            outputs => uo_out
        );
end Behavioral;