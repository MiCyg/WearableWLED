# Wearable WLED
![Work in Progress](https://img.shields.io/badge/status-in--progress-orange)


<p align="center">
	<img src="images/welcome.gif" width="75%" />
</p>


Portable LED controller that makes garments glow. Built around the ESP32-C3 Mini and powered by a Li‑Po battery with a dedicated power switch and a custom button. LED animations are provided by the popular [WLED](https://github.com/Aircoookie/WLED) project. This build uses the Battery usermod to display battery percentage.

## Design goals

- Compact form factor
- Battery-powered operation
- Configurable LED animations
- Easy assembly and mounting
- Low power consumption

WLED uses Wi‑Fi, which increases power consumption; I'm evaluating BLE-based alternatives to reduce battery drain. The project is under active development, and WLED makes configuration straightforward.


## Assembly

<p align="center">
	<img src="images/assembly.gif" width="75%" />
</p>


## Usage

This repository contains three top-level folders:

- `WearableWLED_Mechanical` — Inventor parts and assemblies. STL to download are on my [GrabCad](https://grabcad.com/library/wearablewled-case-1)
- `WearableWLED_Hardware` — KiCad project and PCB files.
- `WLED` — Fork of WLED with configuration adapted for this hardware.

### Clone with submodules

Clone the repository together with all submodules:

```bash
git clone --recurse-submodules https://github.com/MiCyg/WearableWLED.git
```

If you already have the repository cloned:

```bash
git submodule update --init --recursive
```

## Contributing

Contributions are welcome! I'm particularly interested in BLE firmware options, lower-power, and improved mechanical mounting. Open an issue or send a pull request to get involved.

