function fish_greeting
    echo " "
    neofetch
end
#starship init fish | source
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -l -g ""'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
#export STARSHIP_CONFIG=/home/spleenftw/.config/starship/starship.toml


source ~/.bash_aliases
source "$HOME/.config/fish/functions/extract.fish"
set -g theme_date_format "+%a %H:%M"

# Catppuccin macchiato

set fish_color_normal cad3f5
set fish_color_command 8aadf4
set fish_color_param f0c6c6
set fish_color_keyword ed8796
set fish_color_quote a6da95
set fish_color_redirection f5bde6
set fish_color_end f5a97f
set fish_color_comment 8087a2
set fish_color_error ed8796
set fish_color_gray 6e738d
set fish_color_selection --background=363a4f
set fish_color_search_match --background=363a4f
set fish_color_operator f5bde6
set fish_color_escape ee99a0
set fish_color_autosuggestion 6e738d
set fish_color_cancel ed8796
set fish_color_cwd eed49f
set fish_color_cursor eed49f
set fish_color_user 8bd5ca
set fish_color_host 8aadf4
set fish_color_host_remote a6da95
set fish_color_status ed8796
set fish_pager_color_progress 6e738d
set fish_pager_color_prefix f5bde6
set fish_pager_color_completion cad3f5
set fish_pager_color_description 6e738d
#set fish_color_normal white
#set fish_color_autosuggestion grey
#set fish_color_command white
#set fish_color_param brblue
#set fish_color_redirection green

function fish_prompt -d ""
	printf '%s%s%s > ' \
   		(set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

