# Omarchy + Windows Secure Boot (What Worked)

This is the exact flow that worked for enabling Secure Boot with Omarchy + Windows dual-boot without toggling Secure Boot on/off between OSes.

- Primary guide used: <https://github.com/basecamp/omarchy/discussions/2296>
- Reference background: <https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot>

Even though the ArchWiki is the canonical reference, the Omarchy discussion was the practical path that solved this setup on this machine.

## Goal

- Keep Secure Boot enabled all the time.
- Boot both Omarchy and Windows from Limine.

## Preconditions

- UEFI system (not legacy BIOS).
- Limine already installed by Omarchy.
- Windows present as a UEFI boot target.
- `sbctl` installed.

Install tools if needed:

```bash
sudo pacman -S --needed sbctl sbsigntools efitools
```

## Working Setup Steps

1. In firmware (UEFI), set Secure Boot mode to `Custom` and clear keys (Setup Mode).
2. Boot into Omarchy.
3. Recreate local sbctl state and keys:

```bash
sudo rm -rf /var/lib/sbctl
sudo sbctl create-keys
```

4. Enroll keys with Microsoft compatibility:

```bash
sudo sbctl enroll-keys -m
```

5. Confirm key enrollment state:

```bash
sudo sbctl status
sudo sbctl list-enrolled-keys
```

6. Sign all unsigned EFI files:

```bash
sudo sbctl verify | sed -nE 's|^✗ (/.+) is not signed$|sbctl sign -s "\1"|p' | sudo sh
sudo sbctl verify
```

7. Rebuild UKI + Limine config:

```bash
sudo limine-mkinitcpio
```

8. Add Windows entry to Limine menu:

```bash
sudo limine-entry-tool --scan
```

When prompted, select `Windows Boot Manager` (do not cancel).

9. Re-run build + signature verification after menu updates:

```bash
sudo limine-mkinitcpio
sudo sbctl verify
```

10. In firmware (UEFI), enable Secure Boot and keep mode `Custom`.
11. Boot Omarchy and verify:

```bash
sudo sbctl status
bootctl status
```

Expected end state:

- `Secure Boot: enabled (user)` in `bootctl status`
- `Secure Boot: ✓ Enabled` in `sbctl status`

## Notes and Pitfalls

- If Limine does not show Windows, run `sudo limine-entry-tool --scan` again and select Windows.
- `sbctl verify` must be fully signed before enabling Secure Boot.
- `limine-mkinitcpio` may show firmware warnings; this did not block successful setup.
- Earlier attempts with `sbctl enroll-keys -m -f` were unstable on this firmware; `-m` matched the working Omarchy guide.

## Recovery (If Boot Fails)

1. Enter firmware.
2. Set Secure Boot to disabled.
3. If needed, clear keys or restore factory keys to regain boot access.
4. Boot Omarchy and re-run the signing + enrollment flow above.
