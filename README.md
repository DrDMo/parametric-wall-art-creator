# Parametric Wall Art Creator

A Vectric gadget (VCarve / Aspire) for generating parametric wall art toolpaths.

## Features

- Works in both inch and millimeter-based jobs (follows active job units automatically)
- Enforces a clamp margin (default 0.75 in / 19.05 mm) on all sheet edges
- Geometry generation and toolpath generation in two steps
- Generate Toolpaths becomes available after Generate Geometry has been run in the current session

## Installation

Copy the `Parametric Wall Art Creator` folder into your Vectric Gadgets folder, then restart VCarve or Aspire.

Expected structure:
```
Parametric Wall Art Creator/
  Parametric Wall Art Creator.lua
  INSTALL.txt
```

See `INSTALL.txt` for additional notes.

## Files

| File | Description |
|------|-------------|
| `Parametric Wall Art Creator.lua` | Gadget source code |
| `Parametric Wall Art Creator.vgadget` | Packaged gadget (ready to install) |
| `Parametric Wall Art Creator User Guide v2.0.0.docx` | User guide |
| `INSTALL.txt` | Installation instructions |
