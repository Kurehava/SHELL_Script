erro="[\033[91mERRO\033[0m]"
info="[\033[92mINFO\033[0m]"
warn="[\033[93mWARN\033[0m]"
dbug="[\033[95mDBUG\033[0m]"
user_root="$(echo ~)"
if [ "$EUID" = "0" ];then
    ROOT_CHK=true
else
    ROOT_CHK=false
fi
root_sudo="sudo"

if ! $ROOT_CHK;then
    emergency_stop="standby"
    function link_to_root(){
        $root_sudo mkdir -p /root/zsh_backup_temp
        if [ -d /root/.oh-my-zsh ];then
            $root_sudo mv /root/.oh-my-zsh /root/zsh_backup_temp
            back_ohmyzsh="/root/zsh_backup_temp/.oh-my-zsh"
        fi
        if [ -f /root/.zshrc ];then
            $root_sudo mv /root/.zshrc /root/zsh_backup_temp
            back_zshrc="/root/zsh_backup_temp/.zshrc"
        fi
        function rolling_back_errormsg(){
            if [ "$?" != "0" ];then
                emergency_stop="activate"
                echo -e "$erro Roll back failed."
                if [ "$back_ohmyzsh" != "" ] && [ "$back_zshrc" != "" ];then
                    echo -e "$warn Please manually delete the .oh-my-zsh folder and the .zshrc configuration file (if it exists) in the root directory, then copy the backup files from the zsh_backup_temp directory to the root directory and delete the zsh_backup_temp directory."
                elif [ "$back_ohmyzsh" != "" ];then
                    echo -e "$warn Please manually delete the .oh-my-zsh folder(if it exists) in the root directory, then copy the backup files from the zsh_backup_temp directory to the root directory and delete the zsh_backup_temp directory."
                elif [ "$back_zshrc" != "" ];then
                    echo -e "$warn Please manually delete the .zshrc configuration file (if it exists) in the root directory, then copy the backup files from the zsh_backup_temp directory to the root directory and delete the zsh_backup_temp directory."
                fi
            fi
        }
        function rolling_back(){
            operation_target="$1"
            if [ "$?" != "0" ];then
                echo -e "$warn Create soft link to root failed."
                echo -e "$warn Roll back all changes."
                $root_sudo rm -rf "/root/$operation_target"
                if [ "$emergency_stop" = "activate" ];then
                    return 1
                fi
                if [ "$back_ohmyzsh" != "" ];then
                    $root_sudo mv $back_ohmyzsh "/root/$operation_target"
                    rolling_back_errormsg
                    if [ "$emergency_stop" = "activate" ];then
                        return 1
                    fi
                fi
                if [ "$back_ohmyzsh" != "" ];then
                    $root_sudo mv $back_ohmyzsh "/root/$operation_target"
                    rolling_back_errormsg
                    if [ "$emergency_stop" = "activate" ];then
                        return 1
                    fi
                fi
            fi
        }
        $root_sudo ln -s $user_root/.oh-my-zsh /root/.oh-my-zsh
        rolling_back ".oh-my-zsh"
        if [ "$emergency_stop" = "activate" ];then
            return 1
        fi
        $root_sudo ln -s $user_root/.zshrc /root/.zshrc
        rolling_back ".zshrc"
        if [ "$emergency_stop" = "activate" ];then
            return 1
        fi
        $root_sudo chsh -s /bin/zsh "root"
        if [ "$?" != "0" ];then
            echo -e "$erro Switching root default shell to zsh failed, please switch manually."
            echo -e "$info $root_sudo chsh -s /bin/zsh \"root\""
            return 1
        fi
    }
    while :;do
        echo -e "Do you want to apply zsh to the root user?[Y/N]"
        read select_azru
        case $select_azru in
            Y|y) link_to_root;break;;
            N|n) break;;
            *) echo -e "$warn input $select_azru illegal, plz reinput.";;
        esac
    done
fi

while :;do
    echo -e "$info Now we need root."
    echo -e "$info Do you want to automatically reboot now or manually reboot later?[N/L] \c"
    read time_
    case $time_ in
        L|l) echo -e "$info If you want the configuration to take effect,"
             echo -e "$info Please remember to manually reboot later."
             exit 0
             ;;
        N|n) if [ "$root_sudo" = "sudo " ];then
                sudo reboot
             else
                reboot
             fi
             if [ "$?" != "0" ];then
                echo -e "$warn For unknown reasons, we cannot reboot the environment for you."
                echo -e "$warn Please manually restart your environment later to apply the changes."
                echo -e "$warn script exit."
                exit 1
             fi
             exit 0
             ;;
        *) echo -e "$warn input $select is illegal, plz reinput."
    esac
done
