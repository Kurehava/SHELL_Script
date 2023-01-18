erro="[\033[91mERRO\033[0m]"
info="[\033[92mINFO\033[0m]"
warn="[\033[93mWARN\033[0m]"
user_root="$(echo ~)"

# get sudo
sudo pwd > /dev/null

# chk system platform
system_info=`uname -a`
if [[ "$system_info" =~ "WSL" ]];then
    echo -e "$info WSL environment is detected."
    $WSL_ENV="WSL_enable"
else
    $WSL_ENV="WSL_disable"
fi

if [ -f /etc/os-release ];then
    os_plotform=`cat /etc/os-release | grep -w NAME= | awk -F'=' '{print $2}' | awk -F'"' '{print $2}'`
    os_plotform="$os_plotform"
else
    echo -e "$erro Unknown Platform."
    exit 1
fi
echo -e "$info Platform : $os_plotform"

# set package manager
case $os_plotform in
    "Ubuntu") pkg_manage="apt";;
    "CentOS Linux") pkg_manage="yum";;
    "Debian GNU/Linux") pkg_manage="apt";;
    *) pkg_manage="apt";;
esac
echo -e "$info Pkg_manager : $pkg_manage"

# chk zsh shell installed
function shell_check(){
    shell_name=`cat /etc/shells`
    have_zsh="no"

    for shls in ${shell_name[@]};do
        if [[ "$shls" =~ "zsh" ]];then
            have_zsh="zsh"
            echo -e "$info Zsh path : $shls"
        fi
    done
}
shell_check

if [ $have_zsh = "no" ];then
    while :;do
        echo -e "$warn can not found zsh, do you want install zsh?[Y/N] \c"
        read zsh_install
        case $zsh_install in
            Y|y) echo -e "$info + sudo $pkg_manage install -y zsh";`sudo $pkg_manage install -y zsh`;break;;
            N|n) echo -e "$erro not zsh env. exit.";exit 1;;
            *) echo -e "$warn input $zsh_install illegal, plz reinput.";;
        esac
    done
fi

shell_check
if [ $have_zsh = "no" ];then
    echo -e "$erro zsh should already be installed, but we can't detect it."
    echo -e "$erro zsh install failed? maybe error. exit."
    exit 1
fi

# chk download tools
chk_curl="$(which curl)"
chk_wget="$(which wget)"
if [[ ! $chk_curl =~ "not found" ]];then
    download_command="curl"
elif [[ ! $chk_wget =~ "not found" ]];then
    download_command="wget"
else
    while :;do
        echo -e "$warn can not find download tools, do you want install?[Y/N]"
        read selects
        case $select in
            Y|y) $(sudo $pkg_manage install -y curl wget);break;;
            N|n) echo -e "$erro can not download oh-my-zsh, exit." && exit 1;;
            *) echo -e "$warn input $select is illegal, plz reinput.";;
        esac
    done
fi

# install oh-my-zsh
if [ ! -d "$user_root/.oh-my-zsh" ];then
    echo -e "$info Install: oh-my-zsh"
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    # chk install success or fail
    if [ "$($?)" != "0" ];then
        echo -e "$erro Install oh-my-zsh is failed. exit."
        exit 1
    fi
else
    echo -e "$info Detected that oh-my-zsh is already installed, skip the installation."
fi

# set oh-my-zsh dir
omz_home="$user_root/.oh-my-zsh"
omz_themes="$omz_home/themes"
omz_plugins="$omz_home/plugins"

# get kurehava zsh theme
`$download_command "https://raw.githubusercontent.com/Kurehava/SHELL_Script/main/ZSH/Sizuku_double_line.zsh-theme" > "$omz_themes/kurehava_conda.zsh-theme"`

# change theme to kurehava conda theme
$(sed -i s:robbyrussell:kurehava_conda:g "$user_root/.zshrc")

# install plugins
$(sed -i 's:plugins=(git):plugins=(git z extract):g' "$user_root/.zshrc")

incr_path="$omz_plugins/incr"
mkdir "$incr_path"
case $download_command in
    "wget") echo -e "$info DOWNLOAD Plugin: zsh-autosuggestions"
            wget "http://mimosa-pudica.net/src/incr-0.2.zsh" -P "$incr_path"
            incr_install=1
            ;;
    "curl") echo -e "$info DOWNLOAD Plugin: zsh-autosuggestions"
            curl -L "http://mimosa-pudica.net/src/incr-0.2.zsh" -o "$incr_path/incr-0.2.zsh"
            incr_install=1
            ;;
    *) echo -e "$warn Unknown download tool, skip the incr installation for safety reasons."
       echo -e "$warn You can do the manual installation later with the following command."
       echo -e "$warn + wget 'http://mimosa-pudica.net/src/incr-0.2.zsh' -P \"$incr_path\""
       echo -e "$warn + curl 'http://mimosa-pudica.net/src/incr-0.2.zsh' -o \"$incr_path/incr-0.2.zsh\""
       incr_install=0
       ;;
esac
if [ $incr_install = 1 ];then
    if [ -f "$incr_path/incr-0.2.zsh" ];then
        echo -e "source $incr_path/incr-0.2.zsh" >> "$user_root/.zshrc"
        echo -e "$info WRITE: source $incr_path/incr-0.2.zsh >> $user_root/.zshrc"
    else
        echo -e "$warn can not found $incr_path/incr-0.2.zsh"
        echo -e "$warn skip writing incr source to the .zshrc file for security."
        echo -e "$warn You can do the manual installation later with the following command."
        echo -e "$warn + wget 'http://mimosa-pudica.net/src/incr-0.2.zsh' -P \"$incr_path\""
        echo -e "$warn + curl 'http://mimosa-pudica.net/src/incr-0.2.zsh' -o \"$incr_path/incr-0.2.zsh\""
        echo -e "$warn + source $incr_path/incr-0.2.zsh >> $user_root/.zshrc"
    fi
fi

za_path="$omz_plugins/zsh-autosuggestions"
echo -e "$info DOWNLOAD Plugin: zsh-autosuggestions"
mkdir "$za_path"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$za_path"
if [ -f "$za_path/zsh-autosuggestions.zsh" ];then
    echo "source $za_path/zsh-autosuggestions.zsh" >> "$user_root/.zshrc"
    echo -e "$info WRITE: source $za_path/zsh-autosuggestions.zsh >> \"$user_root/.zshrc\""
else
    echo -e "$warn can not found $za_path/zsh-autosuggestions.zsh."
    echo -e "$warn skip writing zsh-autosuggestions source to the .zshrc file for security."
    echo -e "$warn You can do the manual installation later with the following command."
    echo -e "$warn + git clone https://github.com/zsh-users/zsh-autosuggestions.git \"$za_path\""
    echo -e "$warn + source $za_path/zsh-autosuggestions.zsh >> \"$user_root/.zshrc\""
fi

zshl_path="$omz_plugins/zsh-syntax-highlighting"
echo -e "$info DOWNLOAD Plugin: zsh-syntax-highlighting"
mkdir "$zshl_path"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zshl_path"
# echo "source $zshl_path/zsh-syntax-highlighting.zsh" >> "$user_root/.zshrc"
if [ -f "$zshl_path/zsh-syntax-highlighting.zsh" ];then
    echo "source $zshl_path/zsh-syntax-highlighting.zsh" >> "$user_root/.zshrc"
    echo -e "$info WRITE: source $zshl_path/zsh-syntax-highlighting.zsh >> \"$user_root/.zshrc\""
else
    echo -e "$warn can not found $zshl_path/zsh-syntax-highlighting.zsh."
    echo -e "$warn skip writing zsh-syntax-highlighting source to the .zshrc file for security."
    echo -e "$warn You can do the manual installation later with the following command."
    echo -e "$warn + git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \"$zshl_path\""
    echo -e "$warn + source $zshl_path/zsh-syntax-highlighting.zsh >> \"$user_root/.zshrc\""
fi

# change def shell
echo -e "$info change sh to ZSH."
sudo chsh -s /bin/zsh
while :;do
    echo -e "$info Now we need root."
    echo -e "$info Do you want to automatically reboot now or manually reboot later?[N/L] \c"
    read time_
    case $time_ in
        L|l) echo -e "$info If you want the configuration to take effect,"
             echo -e "$info Please remember to manually reboot later."
             exit 0
             ;;
        N|n) sudo reboot
             exit 0
             ;;
        *) echo -e "$warn input $select is illegal, plz reinput."
    esac
done
