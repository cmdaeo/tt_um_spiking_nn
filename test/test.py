import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_spiking_network(dut):
    dut._log.info("Starting LIF Network Simulation")

    # Set up a 50MHz clock (20ns period) to match our info.yaml
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # 1. Initialize the chip's inputs
    dut.ena.value = 1       # Enable the design
    dut.ui_in.value = 0     # All inputs low
    dut.uio_in.value = 0    # All bidirectional IOs low
    dut.rst_n.value = 0     # Assert active-low reset

    # 2. Reset Sequence
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1     # Release reset
    await ClockCycles(dut.clk, 5)

    dut._log.info("Reset complete. Injecting rapid spikes into Neuron 0...")

    # 3. The Stimulus: Forcing Neuron 0 to Fire
    # Our threshold is 200, and our weight is 64. 
    # Because the neuron leaks every cycle, 3 spikes (3 * 64 = 192) won't be enough.
    # We need 4 rapid consecutive spikes to overcome the leak and cross the 200 threshold.
    
    for _ in range(4):
        dut.ui_in.value = 1  # Drive the 0th bit high (Spike into Neuron 0)
        await ClockCycles(dut.clk, 1)
    
    # Immediately drop the input back to 0
    dut.ui_in.value = 0
    
    # 4. Observe the Cascade
    # Now we watch the output pins (which will map to the LEDs on the demo board)
    # We should see Neuron 0 fire, which triggers Neuron 1, which triggers Neuron 2, etc.
    
    dut._log.info("Watching for the cascade effect on uo_out pins:")
    for cycle in range(15):
        await ClockCycles(dut.clk, 1)
        
        # Read the 8-bit output as a binary string (e.g., '00000001')
        output_state = dut.uo_out.value.binstr
        dut._log.info(f"Cycle {cycle:02}: uo_out = {output_state}")
        
        # Assertions to ensure the logic behaves exactly as expected.
        # This will fail the GitHub Action if the math is wrong.
        if cycle == 0:
            assert output_state == "00000001", "Failure: Neuron 0 did not fire!"
        elif cycle == 1:
            assert output_state == "00000010", "Failure: Neuron 1 did not cascade!"
        elif cycle == 2:
            assert output_state == "00000100", "Failure: Neuron 2 did not cascade!"
        elif cycle == 3:
            assert output_state == "00001000", "Failure: Neuron 3 did not cascade!"

    dut._log.info("Simulation complete. Cascade successful!")