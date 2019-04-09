# VHDL Example of serial transceiver and receiver with parity check

The code is just for simulating with vivado the serial tx and rx inside the device. Data is read from a text file and transmmited with parity. The received data is stored in another text file

## Prerequisites

Vivado Design Suite 2017.2 or newer.
It's pure vhdl so it should work in any FPGA IDE, but this example has actually been tested in Vivado 2017.2

## Howto build

- Create a new project in Vivado
- Select the device
- Add simulation sources. Note that the text files are also needed
- Run Simulation
- Check the results in the Behavioral Simulation window

enjoy

Alex
