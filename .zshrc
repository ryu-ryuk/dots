# exports and environment variables
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export EDITOR="nvim"
export BAT_THEME="Catppuccin Mocha"

export PATH="/opt/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/opt/cuda/lib64:$LD_LIBRARY_PATH"
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# install zinit if it doesn't exist
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# source zinit
source "${ZINIT_HOME}/zinit.zsh"

# load and configure completions (must be before plugins)
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# load zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# load zinit snippets (aws removed)
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::kubectl
zinit snippet OMZP::command-not-found
zinit cdreplay -q

# shell options
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

# keybindings
bindkey -e
bindkey '^[[H' beginning-of-line # home
bindkey '^[[F' end-of-line     # end
bindkey '^[[1~' beginning-of-line # Alt home key
bindkey '^[[4~' end-of-line # Alt end key
bindkey '^[[1;5D' backward-word # ctrl+left
bindkey '^[[1;5C' forward-word  # ctrl+right
bindkey '^[[3;5~' kill-word     # ctrl+delete
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^[[3;5~' kill-word

unset ZSH_THEME
# NEWLINE=$'\n'

# update_prompt_colors() {
#     if [[ -f "$HOME/.cache/wal/colors.sh" ]]; then
#         source "$HOME/.cache/wal/colors.sh"
#         export PROMPT="${NEWLINE}%K{$color1}%F{$background} %D{%_I:%M%P} %k%F{$color1}%K{$color2}%F{$background} %n %k%F{$color2}%K{$color4}%F{$background} %~ %k%F{$color4}%f %F{$color6}❯%f "
#     else
#         export PROMPT="${NEWLINE}%K{#313244}%F{#b4befe} %D{%_I:%M%P} %k%F{#313244}%K{#45475a}%F{#cdd6f4} %n %k%F{#45475a}%K{#585b70}%F{#cdd6f4} %~ %k%F{#585b70}%f %F{#b4befe}❯%f "
#     fi
# }

# show_system_info() {
#     if [[ -f "$HOME/.cache/wal/colors.sh" ]]; then
#         source "$HOME/.cache/wal/colors.sh"
#         # Use basic color codes that adapt to terminal theme
#         echo -e "${NEWLINE}\033[44;37m $0 \033[0m\033[46;30m $(uptime -p | cut -c 4-) \033[0m\033[42;30m $(uname -r) \033[0m"
#     else
#         echo -e "${NEWLINE}\033[48;2;180;190;254;38;2;30;30;46m $0 \033[0m\033[48;2;137;180;250;38;2;30;30;46m $(uptime -p | cut -c 4-) \033[0m\033[48;2;116;199;236;38;2;30;30;46m $(uname -r) \033[0m"
#     fi
# }

# autoload -U add-zsh-hook
# add-zsh-hook precmd update_prompt_colors
# show_system_info

# set up prompt
NEWLINE=$'\n'
PROMPT="${NEWLINE}%K{#313244}%F{#b4befe}$(date +%_I:%M%P) %K{#45475a}%F{#cdd6f4} %n %K{#585b70}%F{#cdd6f4} %~ %f%k%F{#b4befe} ❯ %f"
# 
# System information using Lavender, Blue, and Sapphire on Base text
echo -e "${NEWLINE}\033[48;2;49;50;68;38;2;180;190;254m $0 \033[0m\033[48;2;69;71;90;38;2;166;227;161m $(uptime -p | cut -c 4-) \033[0m\033[48;2;88;91;112;38;2;250;179;135m $(uname -r) \033[0m"

# 
# aliases
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias ls='eza --icons=auto'
alias l='eza -lha --icons=auto --sort=name --group-directories-first'
alias t='eza --icons=auto --tree'
alias vim='nvim'
alias vi='nvim'
alias p='sudo pacman'
alias up='$aurhelper -Syu'
alias un='$aurhelper -Rns'
alias clip='wl-copy'
alias s='kitten ssh'
alias d='kitten diff'
alias z='yazi .'
alias mkdir='mkdir -p'
alias foliate='read'

# source other config files
[ -f "$XDG_CONFIG_HOME/shell/alias" ] && source "$XDG_CONFIG_HOME/shell/alias"
[ -f "$XDG_CONFIG_HOME/shell/vars" ] && source "$XDG_CONFIG_HOME/shell/vars"

# initialize tools
eval "$(zoxide init --cmd cd zsh)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
[ -s "/home/ryu/.bun/_bun" ] && source "/home/ryu/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
