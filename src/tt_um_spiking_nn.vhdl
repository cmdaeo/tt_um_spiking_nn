-- ==========================================
-- 1. LIF Neuron Entity & Architecture
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lif_neuron is
    Port ( 
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        spike_in  : in  STD_LOGIC;
        spike_out : out STD_LOGIC
    );
end lif_neuron;

architecture Behavioral of lif_neuron is
    signal v_mem : unsigned(7 downto 0); 
    constant THRESHOLD : unsigned(7 downto 0) := to_unsigned(200, 8);
    constant WEIGHT    : unsigned(7 downto 0) := to_unsigned(64, 8);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                v_mem <= (others => '0');
                spike_out <= '0';
            else
                spike_out <= '0';
                if v_mem >= THRESHOLD then
                    v_mem <= (others => '0'); 
                    spike_out <= '1';
                else
                    if spike_in = '1' then
                        if (v_mem + WEIGHT - shift_right(v_mem, 3)) < 255 then
                            v_mem <= v_mem - shift_right(v_mem, 3) + WEIGHT;
                        else
                            v_mem <= (others => '1');
                        end if;
                    else
                        v_mem <= v_mem - shift_right(v_mem, 3);
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;

-- ==========================================
-- 2. Network Controller Entity & Architecture
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity network_control is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        inputs   : in  STD_LOGIC_VECTOR (7 downto 0);
        outputs  : out STD_LOGIC_VECTOR (7 downto 0)
    );
end network_control;

architecture Behavioral of network_control is
    component lif_neuron is
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            spike_in  : in  STD_LOGIC;
            spike_out : out STD_LOGIC
        );
    end component;

    signal n0_spike, n1_spike, n2_spike, n3_spike : STD_LOGIC;
    signal n0_in, n1_in, n2_in, n3_in : STD_LOGIC;
begin
    n0_in <= inputs(0);
    n1_in <= inputs(1) or n0_spike;
    n2_in <= inputs(2) or n1_spike;
    n3_in <= inputs(3) or n2_spike;

    N0: lif_neuron port map (clk => clk, rst => rst, spike_in => n0_in, spike_out => n0_spike);
    N1: lif_neuron port map (clk => clk, rst => rst, spike_in => n1_in, spike_out => n1_spike);
    N2: lif_neuron port map (clk => clk, rst => rst, spike_in => n2_in, spike_out => n2_spike);
    N3: lif_neuron port map (clk => clk, rst => rst, spike_in => n3_in, spike_out => n3_spike);

    outputs(0) <= n0_spike;
    outputs(1) <= n1_spike;
    outputs(2) <= n2_spike;
    outputs(3) <= n3_spike;
    outputs(7 downto 4) <= (others => '0');
end Behavioral;

-- ==========================================
-- 3. Top-Level Entity & Architecture
-- ==========================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tt_um_spiking_nn is
    Port (
        ui_in   : in  STD_LOGIC_VECTOR (7 downto 0);
        uo_out  : out STD_LOGIC_VECTOR (7 downto 0);
        uio_in  : in  STD_LOGIC_VECTOR (7 downto 0);
        uio_out : out STD_LOGIC_VECTOR (7 downto 0);
        uio_oe  : out STD_LOGIC_VECTOR (7 downto 0);
        ena     : in  STD_LOGIC;
        clk     : in  STD_LOGIC;
        rst_n   : in  STD_LOGIC
    );
end tt_um_spiking_nn;

architecture Behavioral of tt_um_spiking_nn is
    signal rst : STD_LOGIC;
    
    component network_control is
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            inputs   : in  STD_LOGIC_VECTOR (7 downto 0);
            outputs  : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
begin
    rst <= not rst_n;
    uio_out <= (others => '0');
    uio_oe  <= (others => '0');

    net_ctrl: network_control
        port map (
            clk     => clk,
            rst     => rst,
            inputs  => ui_in,
            outputs => uo_out
        );
end Behavioral;