#!/usr/bin/env bash
set -euo pipefail

# Support running both from a local clone and via `curl -fsSL ... | bash`
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/history.toml" ]; then
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    REPO_DIR="$HOME/cliamp-playlists"
    if [ -d "$REPO_DIR/.git" ]; then
        echo "==> Updating existing $REPO_DIR..."
        git -C "$REPO_DIR" pull --ff-only
    else
        echo "==> Cloning sgt-nylle/cliamp-playlists to $REPO_DIR..."
        git clone https://github.com/sgt-nylle/cliamp-playlists.git "$REPO_DIR"
    fi
fi

echo "==> Checking OS and audio dependencies..."
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "==> Detected Windows WSL environment."
    if command -v apt-get >/dev/null 2>&1; then
        echo "==> Installing WSL2 ALSA->PulseAudio bridge and media dependencies..."
        sudo apt-get update
        sudo apt-get install -y curl git libasound2-plugins pulseaudio-utils ffmpeg yt-dlp
    fi

    echo "==> Configuring ~/.asoundrc for WSLg PulseAudio routing..."
    cat > "$HOME/.asoundrc" << 'EOF'
pcm.default pulse
ctl.default pulse
EOF

    if [ -z "${PULSE_SERVER:-}" ]; then
        echo "WARNING: \$PULSE_SERVER is empty. Ensure WSLg is enabled on Windows 11 and run 'wsl --shutdown' from PowerShell if audio does not play."
    else
        echo "==> WSLg PulseAudio detected (PULSE_SERVER=$PULSE_SERVER)."
    fi
elif command -v apt-get >/dev/null 2>&1; then
    echo "==> Detected Debian/Ubuntu Linux."
    sudo apt-get update
    sudo apt-get install -y curl git libasound2-plugins ffmpeg yt-dlp
elif command -v pacman >/dev/null 2>&1; then
    echo "==> Detected Arch Linux."
    sudo pacman -S --needed --noconfirm alsa-lib pipewire-alsa ffmpeg yt-dlp
fi

export PATH="$HOME/.local/bin:$PATH"

if ! command -v cliamp >/dev/null 2>&1; then
    echo "==> Installing cliamp..."
    curl -fsSL https://cliamp.stream/install.sh | sh
else
    echo "==> cliamp is already installed ($(cliamp --version))."
fi

echo "==> Restoring history.toml and importing M3U playlists into cliamp..."
mkdir -p "$HOME/.config/cliamp"
if [ ! -f "$HOME/.config/cliamp/history.toml" ] && [ -f "$REPO_DIR/history.toml" ]; then
    cp "$REPO_DIR/history.toml" "$HOME/.config/cliamp/history.toml"
    echo "    Restored ~/.config/cliamp/history.toml"
fi

for m3u in "$REPO_DIR"/playlists/*.m3u; do
    [ -e "$m3u" ] || continue
    name="$(basename "$m3u" .m3u)"
    cliamp playlist import "$m3u" --name "$name" >/dev/null 2>&1 || true
    echo "    Imported playlist: $name"
done

echo ""
echo "==> Done! Start cliamp with:"
echo "    cliamp"
echo "    cliamp --playlist edm"
echo "    cliamp $REPO_DIR/playlists/recently-played.m3u"
