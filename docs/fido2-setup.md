# FIDO2 Setup (YubiKey for sudo and polkit)

Omarchy ships `omarchy setup security fido2` (also under Omarchy menu → Setup → Security). It installs `libfido2` and `pam-u2f`, registers the plugged-in key in `/etc/fido2/fido2` and prepends `auth sufficient pam_u2f.so cue` to `/etc/pam.d/sudo` and `/etc/pam.d/polkit-1`. `sufficient` means a touch of the key or your password works, so a lost key never locks you out.

## Installation

The install script will prompt you to optionally set up a FIDO2 key. Plug the key in first. If you prefer to set it up manually:

```bash
omarchy setup security fido2
```

Touch the key when it blinks. The script finishes with a `sudo` test that asks for another touch.

## Adding More Keys

Omarchy's setup registers one key, and rerunning it skips registration once `/etc/fido2/fido2` exists. Every key for a user sits on that user's single line, as extra `:`-separated entries, so a new key has to be appended to the end of that line, not added as a new line.

For each extra key, unplug the registered key, plug in the new one and run:

```bash
sudo cp /etc/fido2/fido2 /etc/fido2/fido2.bak
cred="$(pamu2fcfg -n)" && sudo sed -i "s|^${USER}:.*|&${cred}|" /etc/fido2/fido2
```

`pamu2fcfg -n` prints only the new key's entry, without the username. Touch the key when it blinks; if it has a FIDO2 PIN, it asks for that first.

## Verify

```bash
awk -F: -v user="$USER" '$1 == user {print NF-1}' /etc/fido2/fido2   # number of registered keys
sudo -k && sudo true                                                  # asks for a touch
```

Test each key on its own. If something is off, restore the backup with `sudo cp /etc/fido2/fido2.bak /etc/fido2/fido2`.

## Remove

```bash
omarchy remove security fido2
```

This removes the PAM lines, `/etc/fido2` and the `libfido2` and `pam-u2f` packages.

## Notes

- Registrations are tied to the machine's hostname (`pam://<hostname>`), so `/etc/fido2/fido2` cannot be copied to another machine. Register every key on each machine.
- Over SSH, if a registered key is plugged into the remote machine, `sudo` waits for a touch nobody can give, then falls back to the password.
- The lock screen (`/etc/pam.d/omarchy-lock-password`) and LUKS disk unlock do not use the key. Websites (WebAuthn/passkeys) work in Brave without this setup.
