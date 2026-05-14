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
    -- 8-bit register to stay within TinyTapeout logic limits
    signal v_mem : unsigned(7 downto 0); 
    
    -- Configurable parameters (Hardcoded to save gates)
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
                spike_out <= '0'; -- Default state: no spike

                if v_mem >= THRESHOLD then
                    -- FIRE: Threshold crossed
                    v_mem <= (others => '0'); 
                    spike_out <= '1';
                else
                    -- LEAK AND INTEGRATE
                    -- Leak logic: V_mem = V_mem - (V_mem >> 3)
                    -- Integrate logic: Add WEIGHT if spike_in is active
                    if spike_in = '1' then
                        -- Prevent 8-bit overflow during integration
                        if (v_mem + WEIGHT - shift_right(v_mem, 3)) < 255 then
                            v_mem <= v_mem - shift_right(v_mem, 3) + WEIGHT;
                        else
                            v_mem <= (others => '1'); -- Saturate at max value
                        end if;
                    else
                        v_mem <= v_mem - shift_right(v_mem, 3);
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;