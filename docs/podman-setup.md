# Podman Setup

[Podman](https://podman.io/) is a daemonless, rootless container engine. It is used on this machine instead of the Docker daemon so that container commands work as a normal user without `sudo` or membership in the `docker` group (which is effectively passwordless root). This matters when AI agents need to spin up and test containers.

Podman, Podman Desktop and podman-compose are all Apache 2.0 licensed and hosted by the CNCF.

## Installation

Installed automatically via the `CONTAINER_TOOLS` array in `additional-packages.conf`. The install script then enables the user socket, the restart unit and linger.

Manual install if needed:

```bash
yay -S podman podman-compose podman-desktop
systemctl --user enable --now podman.socket
systemctl --user enable podman-restart.service
loginctl enable-linger "$USER"
```

The dotfiles provide the rest:

- `~/.config/containers/registries.conf` sets `docker.io` as the default registry, so short image names like `jellyfin/jellyfin` resolve without an interactive prompt (a prompt would break agents and scripts).
- `docker` is aliased to `podman`, and `docker-compose` to `podman compose`, in `conf.d/aliases.zsh`.
- `DOCKER_HOST` points at the Podman user socket in `conf.d/env.zsh`, so lazydocker, docker-compose and other Docker API clients talk to Podman.

## GPU containers

On machines with an NVIDIA GPU the install script also adds `nvidia-container-toolkit`. Its pacman hook generates the CDI spec at `/etc/cdi/nvidia.yaml` on install and regenerates it on every driver update. Pass the GPU with the same flag under Podman and Docker:

```bash
podman run --rm --device nvidia.com/gpu=0 docker.io/library/ubuntu nvidia-smi
```

The dotfiles `serve.sh` (SGLang profile) uses this flag and picks Podman automatically when it is installed.

## Rootless prerequisites

Rootless Podman needs a subordinate UID/GID range for your user. `useradd` creates one by default on Arch, and the install script adds one if it is missing. Verify with:

```bash
grep "$USER" /etc/subuid /etc/subgid
```

If either line is missing:

```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
podman system migrate
```

## Daily use

```bash
# Same commands as Docker
podman ps
podman logs -f <container>
podman compose -f compose.yaml up -d
podman compose -f compose.yaml down -v

# Quick look at an image without any files
podman run --rm -p 8080:8080 docker.io/searxng/searxng

# Clean up stopped containers, dangling images and unused volumes
podman system prune
```

Persistent services live in `~/dev/containers`, one directory per service with a `compose.yaml`, driven by `manage-containers.sh`.

## GUI and TUI

- **Podman Desktop**: launch from the app menu. It connects to the user socket automatically.
- **lazydocker**: works out of the box thanks to `DOCKER_HOST` from the dotfiles.

## Useful Commands

```bash
# Socket and restart unit status
systemctl --user status podman.socket
systemctl --user status podman-restart.service

# Verify the socket answers
podman --remote info

# Fix host file ownership for a rootless bind mount (runs inside the user namespace)
podman unshare chown -R 1000:1000 ./config
```

## Gotchas

- **Ports below 1024** are not bindable rootless by default. Only needed for services on 80/443:
  ```bash
  echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/99-podman-ports.conf
  sudo sysctl --system
  ```
- **Bind-mount ownership**: files written by root inside a container appear owned by your user on the host. Files written by another in-container UID appear as high UIDs from the subuid range. Use `podman unshare` to inspect or fix them, or add `:U` to the volume mount.
- **Compose files that mount `/var/run/docker.sock`** (Traefik, Portainer) must point at `$XDG_RUNTIME_DIR/podman/podman.sock` instead.
- **`restart: unless-stopped` on boot** only works because `podman-restart.service` and linger are enabled. Without them, rootless containers stay down after a reboot.
- **Do not install `podman-docker`**. It would be harmless once docker is gone, but the shell alias already covers interactive use and the package conflicts with `docker` during the transition.

## Omarchy integration

Verified against the Omarchy source (`~/dev/omarchy`). Omarchy deliberately keeps the user out of the `docker` group because the group is root-equivalent, and gates Docker behind sudo or a polkit prompt instead. That is the reason `docker` needs `sudo` here, and it is also why rootless Podman is the right fit: it gives back sudo-free containers without giving anything running as your user root.

Docker is removed via `uninstall-packages.conf`. What Omarchy does with Docker, and what that means:

| Omarchy piece | Behaviour | After removal |
| --- | --- | --- |
| `docker.socket` enabled | Socket-activated root daemon | Disabled by `uninstall-defaults.sh` before the package is removed. |
| `ufw-docker` + DNS rules in `after.rules` | Stops containers from bypassing the firewall | Package removed with docker. The rules block stays in `/etc/ufw/after.rules` and two `allow-docker-dns` rules remain; both are inert. Rootless Podman uses pasta, so published ports hit the host like any process and ufw's default deny applies. Expose a service on the LAN with `sudo ufw allow <port>`. |
| Super+Shift+D | lazydocker as root via polkit against Docker | Rebound in the dotfiles (`hypr/bindings.lua`) to `lazydocker-podman`, which points lazydocker at the Podman socket. |
| Docker app entry | Same launcher from the app menu | `Docker.desktop` is in the `WEBAPPS` removal list, and the post-update hook removes it again after `omarchy-refresh-applications` re-creates it. |
| Setup > Security > Sudoless Docker | Toggles docker group membership | Menu item still shows. Harmless, do not use it. |
| Install > Development > Docker DB | `sudo docker run` for MySQL/Postgres/Redis | **Stops working.** Run the equivalent `podman run` yourself. |
| Windows VM | `docker compose` under the root daemon | **Stops working.** Reinstall docker if you ever need it. |
| `omarchy-reinstall-pkgs` | Reinstalls every base package, Docker included | Only runs when you ask for it. `omarchy update` does not reinstall removed packages. Re-run `./scripts/uninstall-defaults.sh` afterwards if you use it. |

Nothing in Omarchy touches `~/.config/containers`, the Podman user units or `DOCKER_HOST`.

## Removing Docker

Order matters on a machine that already runs services under Docker: install Podman first, move the services over (below), then remove Docker. Removing the package stops every running Docker container.

```bash
cd ~/dev/crucible-omarchy && ./scripts/uninstall-defaults.sh
```

The script disables `docker.socket` and `docker.service`, removes `docker`, `docker-buildx`, `docker-compose` and `ufw-docker`, and drops the Docker app entry. `lazydocker` stays; it is the TUI for Podman now.

## Handing Jellyfin over to Podman

Directories previously written by the Docker daemon are owned by root. Hand them back to your user before starting the service under Podman:

```bash
sudo chown -R "$USER:$USER" ~/dev/containers/jellyfin/config ~/dev/containers/jellyfin/cache
```

## Servers

Servers running GPU workloads keep Docker. Compose files, images and the mental model are the same, so a service prototyped here deploys there unchanged. The tool follows the machine, the compose file follows the project.
