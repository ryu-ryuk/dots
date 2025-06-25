# exports and environment variables
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export EDITOR="nvim"
export BAT_THEME="Catppuccin Mocha"
# source global shell alias & variables files
[ -f "$XDG_CONFIG_HOME/shell/alias" ] && source "$XDG_CONFIG_HOME/shell/alias"
[ -f "$XDG_CONFIG_HOME/shell/vars" ] && source "$XDG_CONFIG_HOME/shell/vars"

export PATH="/opt/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/opt/cuda/lib64:$LD_LIBRARY_PATH"
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia


# load modules
#
zmodload zsh/complist
autoload -U colors && colors

# install zinit if it doesn't exist
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# source zinit
source "${ZINIT_HOME}/zinit.zsh"

# load and configure completions (must be before plugins)
autoload -U compinit && compinit
zstyle ':completion:*' menu select 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

setopt globdots
setopt interactive_comments

# load zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab


source <(fzf --zsh)
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
HISTSIZE=50000
SAVEHIST=$HISTSIZE

# keybindings
bindkey -e
bindkey '^W' backward-kill-word # ctrl+backspace 

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

unset ZSH_THEME
# set up prompt
#NEWLINE=$'\n'
#PROMPT="${NEWLINE}%K{#313244}%F{#b4befe}$(date +%_I:%M%P) %K{#45475a}%F{#cdd6f4} %n %K{#585b70}%F{#cdd6f4} %~ %f%k%F{#b4befe} ❯ %f"
# nord 


NEWLINE=$'\n'

function build_prompt() {
  local git_branch=""
		if git rev-parse --is-inside-work-tree &>/dev/null; then
		  git_branch=" %K{#313244}%F{#f9e2af} $(git rev-parse --abbrev-ref HEAD 2>/dev/null) %f%k"
		fi


  PROMPT="${NEWLINE}%K{#1e1e2e}%F{#f38ba8}$(date +%_I:%M%P) \
%K{#313244}%F{#cba6f7} %n \
%K{#45475a}%F{#fab387} %~ \
${git_branch}%f%k%F{#a6e3a1} ❯ %f"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd build_prompt

NEWLINE=$'\n'
echo -e "${NEWLINE}\
\033[48;2;17;17;27;38;2;243;139;168m $0 \033[0m\
\033[48;2;49;50;68;38;2;203;166;247m $(uptime -p | cut -c 4-) \033[0m\
\033[48;2;49;50;68;38;2;250;179;135m $(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null | awk '{print $1"%"}') \033[0m\
\033[48;2;49;50;68;38;2;166;227;161m $(uname -r) \033[0m"

# PROMPT="${NEWLINE}%K{$COL0}%F{$COL1}$(date +%_I:%M%P) %K{$COL0}%F{$COL2} %n %K{$COL3} %~ %f%k ❯ " # pywal colors, from postrun script

# set LS_COLORS with catppuccin mocha colors
export LS_COLORS="\
di=38;2;203;166;247:\
ex=38;2;166;227;161:\
ln=38;2;137;180;250:\
or=38;2;243;139;168:\
*.go=38;2;148;226;213:\
*.md=38;2;249;226;175:\
*.zip=38;2;250;179;135:\
*.png=38;2;245;194;231"

# aliases
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
# custom eza/ls configs
alias ls='eza --icons=auto --color=always --group-directories-first'
alias l='eza -lha --icons=auto --color=always --sort=modified --group-directories-first'
alias t='eza --tree --icons=auto --color=always --level=2'
alias lr='eza -lha --icons=auto --color=always --sort=modified --reverse'
alias vim='nvim'
alias vi='nvim'
alias p='sudo pacman'
alias up='$aurhelper -Syu'
alias un='$aurhelper -Rns'
alias clip='wl-copy'
alias ssh='kitten ssh'
alias d='kitten diff'
alias mkdir='mkdir -p'
# alias foliate 


function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

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
export PATH=$PATH:$(go env GOPATH)/bin
