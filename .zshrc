# ~/.zshrc

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# prompt and utilities
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
export RANGER_LOAD_DEFAULT_RC=FALSE

# editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# useful aliases (non-personal)
alias vim='nvim'
alias python='python3'
alias qemu='qemu-system-x86_64'
