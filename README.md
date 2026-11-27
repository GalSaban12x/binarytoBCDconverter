# 8-bit Binary to BCD Converter (VHDL)

A sequential **8-bit unsigned binary-to-BCD converter** implemented in VHDL. The design uses a binary down-counter and three cascaded decimal (modulo-10) up-counters to generate the hundreds, tens, and units digits. The digits are decoded for active-low seven-segment displays.

> This project implements a **counter-based conversion**, not the combinational Double Dabble algorithm.

## Architecture

```text
                     +----------------------+
din[7:0] --start---->| 8-bit down-counter   |---- count_enable ----+
                     |      bindown         |                      |
                     +----------------------+                      v
                                          +-----------+   tc  +-----------+  tc  +-----------+
                                          | units BCD |------>| tens BCD  |----->| hundreds  |
                                          |  bcdup    |       |  bcdup    |      |   bcdup   |
                                          +-----------+       +-----------+      +-----------+
                                                |                   |                   |
                                           7-seg decode       7-seg decode       7-seg decode
                                                |                   |                   |
                                               HEX0                HEX1                HEX2
```

The converter loads the binary value on `start`, clears the BCD counters, and counts down once per clock while counting the BCD digits upward. When the down-counter reaches zero, `ready` is asserted.

## Project visuals

The following figures were captured during development of the original project. They document the counter-based design and a simulation session; they are **not** presented as proof that the updated regression test has passed.

### Block diagram

The project diagram shows the input binary down-counter and three cascaded BCD up-counters for the units, tens, and hundreds digits. The down-counter drives the counter-enable signal, while the cascaded terminal-count signals propagate decimal carries. The resulting digits are exposed through the original BCD-output interface shown in the diagram.

> **Interface note:** The original schematic screenshots show `dout_low`, `dout_mid`, and `dout_high`. The current repository top level instead exposes the encoded seven-segment outputs `HEX0`, `HEX1`, and `HEX2`.

<!-- Once docs/architecture-diagram.jpeg has been uploaded, uncomment:
![Original block diagram](docs/architecture-diagram.jpeg)
-->

### RTL hierarchy / schematic view

The Quartus schematic shows how `bindown` and the three instances of `bcdup` are connected. It provides a visual counterpart to the RTL hierarchy.

<!-- Once docs/rtl-view.jpeg has been uploaded, uncomment:
![Quartus schematic view](docs/rtl-view.jpeg)
-->

### Simulation waveform

A waveform screenshot from the original project shows `clk`, `resetN`, `start`, `din`, three BCD digit outputs, and the `ready` signal. It illustrates the counting process for example input values; the screenshot alone does not establish exhaustive verification.

<!-- Once docs/simulation-waveform.jpeg has been uploaded, uncomment:
![Original simulation waveform](docs/simulation-waveform.jpeg)
-->

## Interface

| Signal | Direction | Description |
| --- | --- | --- |
| `clk` | in | System clock |
| `resetN` | in | Active-low asynchronous reset |
| `start` | in | Synchronous load of `din` and clear of BCD digits |
| `din[7:0]` | in | Unsigned input (0–255) |
| `ready` | out | High when conversion is not counting (including before the first start) |
| `HEX0[6:0]` | out | Active-low seven-segment units digit |
| `HEX1[6:0]` | out | Active-low seven-segment tens digit |
| `HEX2[6:0]` | out | Active-low seven-segment hundreds digit |

### Example

For `din = 173`, the final displayed digits are `1` (hundreds), `7` (tens), and `3` (units). The BCD digits represent `0001_0111_0011`.

## Files

| Path | Purpose |
| --- | --- |
| `rtl/bin2bcd.vhd` | Top-level converter |
| `rtl/bindown.vhd` | 8-bit binary down-counter |
| `rtl/bcdup.vhd` | Decimal up-counter with carry |
| `rtl/hexsse.vhd` | Active-low seven-segment decoder |
| `tb/tb_bin2bcd.vhd` | Original testbench retained for reference (legacy interface; not compatible with current top-level ports) |
| `tb/tb_bin2bcd_selfcheck.vhd` | Automated testbench covering input values 0–255 |
| `quartus/bin2bcd.qpf` / `quartus/bin2bcd.pin` | Original Quartus artifacts |

## Run the self-checking testbench (GHDL)

If GHDL is installed:

```bash
ghdl -a --std=08 rtl/bcdup.vhd rtl/bindown.vhd rtl/hexsse.vhd rtl/bin2bcd.vhd tb/tb_bin2bcd_selfcheck.vhd
ghdl -e --std=08 tb_bin2bcd_selfcheck
ghdl -r --std=08 tb_bin2bcd_selfcheck --assert-level=error
```

The testbench checks all 256 possible input values, including the boundary values 0, 9, 10, 99, 100, and 255, by checking the seven-segment outputs against expected decimal digits after conversion completes. It also checks the `ready` handshake and includes a mid-conversion restart test.

**Verification status:** The testbench has been added but has not been executed in a simulator in this environment. Simulation and synthesis results are not claimed.

## Design trade-off

This implementation uses repeated counting, so conversion latency scales with the input value (up to 255 clock cycles after the load edge). It reuses simple counter logic instead of a combinational or iterative shift/add-3 converter.

See [`docs/architecture.md`](docs/architecture.md) for an architecture diagram and verification notes. The original Quartus `.pin` file is a generated report, not a pin-assignment input; a complete reusable Quartus project would also need its actual `.qsf` settings file, which is not present in this repository.

## Further work

- Run the self-checking testbench in GHDL or ModelSim and attach genuine logs/waveforms.
- Run synthesis in Quartus; record target device, resource utilization, Fmax and constraints.
- Optionally compare the counter-based architecture with Double Dabble for latency and resource utilization.

## Attribution

The original source files contain template attribution to Amos Zaslavsky / aztech.co.il. This documentation and the new self-checking testbench are enhancements to the existing repository. Attribution comments in the original RTL are preserved.
