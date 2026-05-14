## How it works

This project is a 4-neuron Leaky Integrate-and-Fire (LIF) spiking neural network implemented natively in VHDL. It breaks away from standard logic and enters the realm of neuromorphic engineering. 

The network uses a cascading topology. The LIF math relies entirely on addition, subtraction, and right-shifting (to simulate the "leak" decay) rather than hardware multipliers, allowing it to easily fit inside the strict logic gate constraints of the shuttle. When a neuron's membrane potential crosses a threshold of 200, it emits a spike and resets. The output of Neuron 0 feeds into Neuron 1, creating a temporal cascade.

## How to test

To test the physical silicon, provide a continuous high signal (hold the button down) on Input 0 to continuously inject spikes into Neuron 0. Because the neurons constantly "leak" voltage, a single spike is not enough to trigger a cascade. 

Hold the input until Neuron 0's internal register overcomes the leak factor and crosses the threshold. When Neuron 0 fires, it will emit a spike on Output 0 (LED 0) and forward a spike to Neuron 1. Watch the output pins to observe the asynchronous, rhythmic cascading ripple effect across the network.

## External hardware

No external hardware is required. The design is fully compatible with the standard TinyTapeout demo board. Inputs can be driven by the onboard dip switches or push buttons, and the spiking outputs will be visibly routed directly to the onboard LEDs.