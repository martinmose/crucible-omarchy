# Keyd Danish Character Setup

This setup configures `keyd` to provide Danish character shortcuts using Alt key combinations.

## What it does

Maps Alt keys to layer mode for Danish characters using Unicode input sequences.

## Requirements

- `keyd` package must be installed

## Usage

```bash
./scripts/setup-keyd.sh
```

## Manual Setup

If you prefer to set it up manually:

1. Install keyd: `sudo pacman -S keyd`
2. Copy config: `sudo cp default.conf /etc/keyd/default.conf`
3. Enable service: `sudo systemctl enable --now keyd`

## Configuration

The configuration is stored in `default.conf` and uses Unicode input sequences (C-S-u) to generate the Danish characters.