# Initialise Startship prompt
eval "$(starship init zsh)"

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export PATH="/opt/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/opt/cuda/lib64:$LD_LIBRARY_PATH"


# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"


# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found


# Common plugins
#
plugins=(
  colored-man-pages
  common-aliases
  docker
  dotenv
  extract
  history
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q


# Keybindings
bindkey '^[[H' beginning-of-line # Home key
bindkey '^[[F' end-of-line  # End key
bindkey '^[[1~' beginning-of-line # Alt home key
bindkey '^[[4~' end-of-line # Alt end key

bindkey '^[[1;5D' backward-word # ctrl+left
bindkey '^[[1;5C' forward-word  # ctrl+right
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^[[3;5~' kill-word
# bindkey "^[[3~" delete-char
# bindkey "^[[3;5~" delete-word


# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias fbat="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

alias inv='nvim $(fzf -m --preview="bat --color=always {}")'

EDITOR="nvim"

# alias cd='zoxide'
alias c='clear' # clear terminal
alias la='eza -lh --icons=auto' #la
alias ls='eza --icons=auto' # short list
alias l='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias t='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurh>
alias vc='code' # gui code editor
alias z='yazi' # yazi file manager
alias vim='nvim'
alias clip='wl-copy'
alias foliate='read'
alias pipes='~/.config/scripts/pipes.sh/pipes.sh'
alias icat='kitten icat'
alias s='kitten ssh'
alias d='kitten diff'
alias mkdir='mkdir -p'
alias n='nvim'
alias p='sudo pacman'
alias t='tree .'

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

export PATH=$PATH:/home/ryu/.spicetify
export BAT_THEME="Catppuccin Mocha"
eval "$(zoxide init --cmd cd zsh)"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
