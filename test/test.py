import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_spiking_network(dut):
    dut._log.info("Starting LIF Network Simulation")

    # Set up a 50MHz clock (20ns period)
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # 1. Initialize the chip's inputs
    dut.ena.value = 1       
    dut.ui_in.value = 0     
    dut.uio_in.value = 0    
    dut.rst_n.value = 0     

    # 2. Reset Sequence
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1     
    await ClockCycles(dut.clk, 5)

    dut._log.info("Holding Input 0 HIGH to continuously stimulate the network...")

    # 3. The Stimulus
    # We will hold the button down for 50 clock cycles and actively monitor the LEDs.
    dut.ui_in.value = 1  
    
    n0_fire_count = 0
    
    for cycle in range(50):
        await ClockCycles(dut.clk, 1)
        
        # Read the 8-bit output as an integer
        out_val = int(dut.uo_out.value)
        
        # Use bitwise AND to check if the 0th LED (Neuron 0) is flashing
        if (out_val & 1):
            n0_fire_count += 1
            dut._log.info(f"Cycle {cycle:02}: BOOM! Neuron 0 FIRED!")

    # 4. The Final Assertion
    # If Neuron 0 fired at least once, our Integrate-and-Fire math is physically proven.
    assert n0_fire_count > 0, "Failure: Neuron 0 never fired! The math is stalled."
    
    dut._log.info(f"Success! Neuron 0 fired {n0_fire_count} times during the hold.")
    dut._log.info("Simulation complete. Silicon physics verified!")