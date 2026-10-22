# cliamp Playlists & Remote Setup

Personal M3U playlists and setup instructions for [cliamp](https://github.com/bjarneo/cliamp) across remote Linux machines and Windows WSL2 (Ubuntu).

---

## Quick Start (Automated Setup)

Run this one-liner on any remote Linux system or Windows WSL2 (Ubuntu) to install `cliamp`, configure audio (including WSLg PulseAudio routing), clone the playlists, and import all `.m3u` files:

```bash
curl -fsSL https://raw.githubusercontent.com/sgt-nylle/cliamp-playlists/main/install.sh | bash
```

Or clone manually with `git` (no authentication required):

```bash
git clone https://github.com/sgt-nylle/cliamp-playlists.git ~/cliamp-playlists
cd ~/cliamp-playlists
./install.sh
```

---

## Manual Installation & Setup

### 1. Install `cliamp`

**Official Installer (Linux / WSL Ubuntu / macOS):**
```bash
curl -fsSL https://cliamp.stream/install.sh | sh
```
> Ensure `~/.local/bin` is in your `PATH`:
> ```bash
> echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
> ```

**Optional Runtime Dependencies (AAC/Opus/YouTube support):**
```bash
# Ubuntu / Debian / WSL
sudo apt update && sudo apt install -y ffmpeg yt-dlp

# Arch Linux (Omarchy)
yay -S cliamp ffmpeg yt-dlp
```

---

### 2. Configure Audio on Windows WSL2 (Ubuntu)

`cliamp` uses ALSA on Linux. Because WSL2 does not expose hardware ALSA devices directly, ALSA must be routed through WSLg's built-in PulseAudio server.

If you encounter `audio output unavailable` or `ALSA lib pcm.c: Unknown PCM default`:

1. **Install the ALSA PulseAudio bridge & utilities:**
   ```bash
   sudo apt update
   sudo apt install -y libasound2-plugins pulseaudio-utils
   ```

2. **Route ALSA default output through PulseAudio (`~/.asoundrc`):**
   ```bash
   cat > ~/.asoundrc << 'EOF'
   pcm.default pulse
   ctl.default pulse
   EOF
   ```

3. **Verify WSLg Audio is Active:**
   ```bash
   echo "$PULSE_SERVER"
   # Should print: unix:/mnt/wslg/PulseServer
   ```
   - Test audio connection with `pactl info`.
   - If `$PULSE_SERVER` is empty or audio fails, update WSL in Windows PowerShell (`wsl --update`), restart WSL (`wsl --shutdown`), and reopen your Ubuntu terminal.

---

### 3. Configure Audio on Native Linux

If `cliamp` reports `audio output unavailable` on a standard Linux desktop/server, install the ALSA bridge for your sound server:

```bash
# Ubuntu / Debian (PulseAudio)
sudo apt install -y libasound2-plugins

# Ubuntu / Debian (PipeWire)
sudo apt install -y pipewire-alsa

# Arch Linux (PipeWire)
sudo pacman -S pipewire-alsa

# Arch Linux (PulseAudio)
sudo pacman -S pulseaudio-alsa
```

---

### 4. Download & Load Playlists

#### Clone the Repository
```bash
git clone git@github.com:sgt-nylle/cliamp-playlists.git ~/cliamp-playlists
cd ~/cliamp-playlists
```

#### Play an `.m3u` Playlist Directly
```bash
# Play your Recently Played playlist
cliamp ~/cliamp-playlists/playlists/recently-played.m3u

# Play the EDM or Lofi playlist
cliamp ~/cliamp-playlists/playlists/edm.m3u
cliamp ~/cliamp-playlists/playlists/lofi.m3u

# Play 24/7 radio streams
cliamp ~/cliamp-playlists/playlists/streams.m3u
```

#### Import Playlists Permanently into `cliamp`
```bash
# Import a single M3U playlist into cliamp's local library
cliamp playlist import ~/cliamp-playlists/playlists/recently-played.m3u --name "Recently Played"
cliamp playlist import ~/cliamp-playlists/playlists/edm.m3u --name "edm"

# Or import all M3U playlists at once
for f in ~/cliamp-playlists/playlists/*.m3u; do
  cliamp playlist import "$f" --name "$(basename "$f" .m3u)"
done

# Start cliamp directly with an imported playlist
cliamp --playlist edm
```

#### Restore `Recently Played` History (`history.toml`)
```bash
mkdir -p ~/.config/cliamp
cp ~/cliamp-playlists/history.toml ~/.config/cliamp/history.toml
```

---

## Included Playlists (`playlists/`)

| File | Description | Tracks |
| :--- | :--- | ---: |
| `recently-played.m3u` | System `Recently Played` tracks & streams | 26 |
| `streams.m3u` | All 15 live 24/7 `cliamp.stream` radio channels | 15 |
| `all-tracks.m3u` | Combined playlist of all tracks across all stations | 1,134 |
| `edm.m3u` | EDM (`1000 Handz` & House/Electronic instrumentals) | 100 |
| `lofi.m3u` | Lofi Chill Beats | 120 |
| `synthwave.m3u` | Synthwave / Retro | 100 |
| `omarchy.m3u` | Omarchy curated tracks | 33 |
| `meditative.m3u` | Meditative / Ambient | 25 |
| `chiptune.m3u` | Chiptunes / 8-bit | 108 |
| `amiga.m3u` | Amiga Demoscene / Mod tracks | 68 |
| `ncs.m3u` | NoCopyrightSounds (Main) | 48 |
| `ncs-house.m3u` | NCS House | 99 |
| `ncs-dubstep.m3u` | NCS Dubstep | 80 |
| `ncs-dnb.m3u` | NCS Drum & Bass | 100 |
| `ncs-trap.m3u` | NCS Trap | 100 |
| `ncs-phonk.m3u` | NCS Phonk | 60 |
| `ncs-pop.m3u` | NCS Pop | 56 |
| `ncs-chill.m3u` | NCS Chill | 37 |
