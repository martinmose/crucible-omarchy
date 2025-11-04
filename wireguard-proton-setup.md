# WireGuard Setup for Proton VPN

This guide explains how to set up WireGuard to connect to Proton VPN.

## Setup

1. Download your WireGuard configuration from [account.protonvpn.com/downloads](https://account.protonvpn.com/downloads)

2. Move and secure the configuration file:
```bash
sudo mv ~/Downloads/arch-hyprland.conf /etc/wireguard/proton.conf
sudo chmod 600 /etc/wireguard/proton.conf
```

3. Connect to VPN:
```bash
sudo wg-quick up proton
```

4. Disconnect from VPN:
```bash
sudo wg-quick down proton
```
