export DEVKITPRO=/opt/devkitpro
export DEVKITARM=/opt/devkitpro/devkitARM
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=/opt/devkitpro/devkitARM
export GBDK_HOME=~/Desktop/weird\ coding/gameboy-tools/gbdk
export PATH="$PATH:$GBDK_HOME/bin"
export GBDK_HOME=~/gbdk
export PATH="$PATH:$GBDK_HOME/bin"
export JAVA_HOME=$(/usr/libexec/java_home -v21)
export PATH=$JAVA_HOME/bin:$PATH
alias vim='nvim'
alias python='python3'
alias qemu=qemu-system-x86_64
alias cdprojects='cd /Users/familie/Desktop/alles/codingzeug'
alias coding='bash ~/.config/start.sh'
export EDITOR="nvim"
export VISUAL="$EDITOR"
eval "$(starship init zsh)"

export RANGER_LOAD_DEFAULT_RC=FALSE
export VK_LAYER_PATH=/Users/familie/VulkanSDK/1.4.321.0/macOS/share/vulkan/explicit_layer.d
export VK_ICD_FILENAMES=/Users/familie/VulkanSDK/1.4.321.0/macOS/share/vulkan/icd.d/MoltenVK_icd.json

export CONNECTIQ_SDK="$HOME/Library/Application\ Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.3-2025-08-11-cac5b3b21"
export PATH="$CONNECTIQ_SDK/bin:$PATH"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
