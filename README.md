Here is a short `README.md` you can use for the `vsd-dft` repo.

````markdown
# VSD DFT Lab

This repository provides a cloud-ready Digital Design for Testability (DFT) lab environment using open-source tools.

The flow demonstrates basic DFT steps such as synthesis, flip-flop cutting, scan-chain insertion, ATPG, JTAG TAP insertion, and simulation using Fault, Yosys, Icarus Verilog, Pyverilog, Quaigh, and OSS CAD Suite.

## Tools Included

The Codespace environment includes:

- Fault DFT toolchain
- Yosys
- ABC
- Icarus Verilog
- VVP
- Pyverilog
- Quaigh
- Graphviz
- noVNC desktop environment

## Running on GitHub Codespaces

1. Open this repository on GitHub.
2. Click `Code`.
3. Select `Codespaces`.
4. Click `Create codespace on main`.
5. Wait for the environment to finish setting up.

Once the Codespace opens, run:

```bash
bash scripts/verify_tools.sh
````

This checks whether all required tools are installed correctly.

## Initialize Lab Folders

Run:

```bash
bash scripts/init_dft_workspace.sh
```

This creates the required output folders:

```text
synth/
cut/
scan/
JTAG/
logs/
report/
atpg/
schematic/
simulation/
```

## Check Fault Installation

Run:

```bash
fault --help
```

Expected output:

```text
OVERVIEW: Open-source EDA's missing DFT Toolchain

USAGE: fault <subcommand>
```

## noVNC Desktop

The Codespace forwards port `6080` for the browser-based desktop.

To open the desktop:

1. Go to the `PORTS` tab in Codespaces.
2. Find port `6080`.
3. Open it in the browser.

## Repository Structure

```text
vsd-dft/
├── .devcontainer/
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── supervisord.conf
├── scripts/
│   ├── init_dft_workspace.sh
│   └── verify_tools.sh
├── rtl/
├── lib/
├── State_Diagram/
└── README.md
```

## Notes

Generated outputs should not be committed to the repository. Lab output folders such as `synth/`, `cut/`, `scan/`, `logs/`, `report/`, `atpg/`, `schematic/`, and `simulation/` are meant to be created during runs.

## Purpose

This repo is intended for students and engineers who want to learn practical DFT concepts using an open-source cloud-based setup without installing tools locally.

```
```
