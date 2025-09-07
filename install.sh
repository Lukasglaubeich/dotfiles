
#!/usr/bin/env bash
set -e

# =========================
# Dotfiles Installer Script
# =========================

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d%H%M%S)"

echo "Dotfiles directory: $DOTFILES_DIR"
echo "Backup directory: $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"

# Function to backup and copy
copy_file() {
    local src=$1
    local dest=$2

    if [ -e "$dest" ]; then
        echo "Backing up $dest -> $BACKUP_DIR"
        mkdir -p "$(dirname "$BACKUP_DIR/$dest")"
        mv "$dest" "$BACKUP_DIR/$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
    echo "Copied $src -> $dest"
}

echo "Installing .zshrc..."
copy_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

echo "Installing .tmux.conf..."
copy_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Copy .config folder contents recursively
echo "Installing .config files..."
for item in "$DOTFILES_DIR/.config"/*; do
    name=$(basename "$item")
    copy_file "$item" "$HOME/.config/$name"
done

echo "Installation complete!"
echo "Backup of previous configs stored at: $BACKUP_DIR"
