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

    dut._log.info("Injecting 6 rapid spikes to guarantee threshold crossing...")

    # 3. The Stimulus
    for _ in range(6):
        dut.ui_in.value = 1  
        await ClockCycles(dut.clk, 1)
    
    dut.ui_in.value = 0
    
    dut._log.info("Watching for the cascade effect on uo_out pins:")

    # 4. Wait for Neuron 0 to fire (allowing for hardware propagation delay)
    n0_fired = False
    for _ in range(10):
        await ClockCycles(dut.clk, 1)
        if dut.uo_out.value.binstr == "00000001":
            n0_fired = True
            break
            
    assert n0_fired, "Failure: Neuron 0 did not fire!"
    dut._log.info("Neuron 0 Fired! Verifying the cascade...")

    # 5. Once Neuron 0 fires, the rest should cascade on exactly the next clock edges
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value.binstr == "00000010", f"Failure: Neuron 1 failed! Got {dut.uo_out.value.binstr}"
    
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value.binstr == "00000100", f"Failure: Neuron 2 failed! Got {dut.uo_out.value.binstr}"
    
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value.binstr == "00001000", f"Failure: Neuron 3 failed! Got {dut.uo_out.value.binstr}"

    dut._log.info("Simulation complete. Cascade successful!")