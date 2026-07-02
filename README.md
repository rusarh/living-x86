# Livingstone Supongo (DOS) — Source Code Disassembly & Reverse Engineering

[![License: MIT](https://shields.io)](https://opensource.org)
[![Platform: DOS](https://shields.io)]()
[![Language: x86 ASM](https://shields.io)]()

A complete, structured 16-bit x86 Assembly reverse engineering project and disassembly for **Livingstone Supongo** (released internationally as *Livingstone, I Presume?*), the legendary 1986 platformer developed by **Opera Soft**. 

Unlike the 8-bit Z80 versions (Amstrad CPC, ZX Spectrum, MSX), this repository focuses entirely on documenting, rebuilding, and preserving the internal mechanics, memory maps, and graphics engine of the IBM PC / MS-DOS release.

---

## 🧭 Repository Structure

The source tree separates game modules into distinct assembly (`.ASM`) and include (`.INC`) files, decoupling system I/O from core engine logic:

### Core Executable Components
*   **`LSTONE.ASM` / `LSTONE2.asm` / `LSTONE3.asm`**: The main entry points, initialization routines, and primary gameplay loops.
*   **`LMIN.ASM` / `LMINREC.ASM` / `LSTONREC.ASM`**: Recovered+commented and minimal demo system files.

### Hardware & I/O Subsystems
*   **`KEYBOARD.INC`**: Low-level interrupt handlers (`INT 9h`) for responsive multi-key input.
*   **`SOUND.ASM` / `SOUNDDAT.INC`**: PC-Speaker frequency drivers, tone matrices, and audio sequencing routines.

### Engine Assets & State Machines
*   **`ROOMOBJ.INC` / `LOCMAP.INC`**: Layout configurations, screen definitions, and room transition tables.
*   **`OBJPROC.ASM` / `OBJFRDAT.INC` / `OBJGRAPH.INC`**: Sprite rendering pipelines, frame animation data, and collision boundaries.
*   **`LOCOBJ.INC` / `OBJSTAT.INC`**: Inventory management, player mechanics (pole vault, boomerang, knife, grenades), and enemy state tracking.
*   **`VARDAT.INC` / `LSTONE.DEF`**: Core global variable definitions, segment registers, and RAM offset definitions.

---

## 🛠️ How to Assemble / Build

The codebase includes specialized MS-DOS batch scripts to automate compiling, linking, and packaging. 

### Prerequisites
To assemble the codebase into a playable binary, you will need a 16-bit Real Mode x86 assembler running within an MS-DOS environment (or via **DOSBox**):
*   **MASM** (Microsoft Macro Assembler v5.0+) or **TASM** (Turbo Assembler).
*   **LINK.EXE** (compatible 16-bit segment linker).

### Automated Compilation Scripts
Run the automated tools via your DOS command prompt:

*   `m.bat` / `lm.bat`: Compiles individual modified modules.
*   `master.bat`: Triggers a clean top-down build of all project source segments.
*   `l.bat` / `o.bat`: Automated linking macros to cleanly output the final executable target.

---

## 🎮 Game Engine & Technical Details

*   **Processor Target:** Intel 8086 / 8088 Real Mode (16-bit).
*   **Graphics Standard:** Standard IBM PC CGA/EGA video memory configurations utilized by early Opera Soft ports.
*   **Timing Hooks:** Traps the system timer chip to guarantee consistent game loop execution across varying CPU clock cycles.

---

## 🤝 Contributing & Goals

The ultimate target for this codebase is to create a **100% byte-perfect, rebuildable source tree** of the original retail release. 

Contributions are highly encouraged! Feel free to:
1. Document undocumented memory offsets in `VARDAT.INC`.
2. Add detailed structural layout comments to raw instructions in `LSTONE.ASM`.
3. Fix potential emulation timing quirks.

## 📄 License

This disassembly project is intended strictly for educational, archival, and reverse-engineering preservation purposes. Code structures and documentation are shared under the **MIT License**. Original game assets and intellectual property belong exclusively to their respective legacy rights holders.
