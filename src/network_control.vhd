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
    -- Declare the neuron component we wrote earlier
    component lif_neuron is
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            spike_in  : in  STD_LOGIC;
            spike_out : out STD_LOGIC
        );
    end component;

    -- Internal signals to route the spikes between neurons
    signal n0_spike, n1_spike, n2_spike, n3_spike : STD_LOGIC;
    signal n0_in, n1_in, n2_in, n3_in : STD_LOGIC;

begin
    -- The Topology: A Cascading Chain Reaction
    
    -- Neuron 0: Driven purely by the user pushing button 0 on the demo board
    n0_in <= inputs(0);

    -- Neuron 1: Driven by user button 1 OR a spike from Neuron 0
    n1_in <= inputs(1) or n0_spike;

    -- Neuron 2: Driven by user button 2 OR a spike from Neuron 1
    n2_in <= inputs(2) or n1_spike;

    -- Neuron 3: Driven by user button 3 OR a spike from Neuron 2
    n3_in <= inputs(3) or n2_spike;

    -- Instantiate the 4 Neurons
    N0: lif_neuron port map (clk => clk, rst => rst, spike_in => n0_in, spike_out => n0_spike);
    N1: lif_neuron port map (clk => clk, rst => rst, spike_in => n1_in, spike_out => n1_spike);
    N2: lif_neuron port map (clk => clk, rst => rst, spike_in => n2_in, spike_out => n2_spike);
    N3: lif_neuron port map (clk => clk, rst => rst, spike_in => n3_in, spike_out => n3_spike);

    -- Map the neuron spikes directly to the first 4 output pins (LEDs)
    outputs(0) <= n0_spike;
    outputs(1) <= n1_spike;
    outputs(2) <= n2_spike;
    outputs(3) <= n3_spike;
    
    -- Ground the remaining 4 unused outputs to prevent floating pins
    outputs(7 downto 4) <= (others => '0');

end Behavioral;