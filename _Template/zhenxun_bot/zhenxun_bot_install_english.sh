#!/usr/bin/env bash
update_shell_url="https://raw.githubusercontent.com/zhenxun-org/zhenxun_bot-deploy/master/install.sh"
zhenxun_url="https://github.com/HibiKier/zhenxun_bot.git"
WORK_DIR="/home"
TMP_DIR="$(mktemp -d)"
python_v="python3.8"
which python3.9 > /dev/null 2>&1 && python_v="python3.9"
sh_ver="1.0.4"
ghproxy="https://ghproxy.com/"
mirror_url="https://pypi.org/simple"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[INFO]${Font_color_suffix}"
Error="${Red_font_prefix}[ERRO]${Font_color_suffix}"
Tip="${Green_font_prefix}[WARN]${Font_color_suffix}"

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} The current non-ROOT account (or no ROOT permission), can not continue to operate, please replace the ROOT account or use ${Green_background_prefix}sudo -i${Font_color_suffix} command to obtain temporary ROOT privileges (you may be prompted for the password of your current account after execution)." && exit 1
}

#检查系统
check_sys() {
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif grep -q -E -i "debian" /etc/issue; then
        release="debian" 
    elif grep -q -E -i "ubuntu" /etc/issue; then
        release="ubuntu"
    elif grep -q -E -i "centos|red hat|redhat" /etc/issue; then
        release="centos"
    elif grep -q -E -i "Arch|Manjaro" /etc/issue; then
        release="archlinux"
    elif grep -q -E -i "debian" /proc/version; then
        release="debian"
    elif grep -q -E -i "ubuntu" /proc/version; then
        release="ubuntu"
    elif grep -q -E -i "centos|red hat|redhat" /proc/version; then
        release="centos"
    else
        echo -e "zhenxun_bot This Linux distribution is not supported at this time" && exit 1
    fi
    bit=$(uname -m)
}

check_installed_zhenxun_status() {
  [[ ! -e "${WORK_DIR}/zhenxun_bot/bot.py" ]] && echo -e "${Error} zhenxun_bot Not installed, please check !" && exit 1
}

check_installed_cqhttp_status() {
  [[ ! -e "${WORK_DIR}/go-cqhttp/go-cqhttp" ]] && echo -e "${Error} go-cqhttp Not installed, please check !" && exit 1
}

check_pid_zhenxun() {
  #PID=$(ps -ef | grep "sergate" | grep -v grep | grep -v ".sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}')
  PID=$(pgrep -f "bot.py")
}

check_pid_cqhttp() {
  #PID=$(ps -ef | grep "sergate" | grep -v grep | grep -v ".sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}')
  PID=$(pgrep -f "go-cqhttp")
}

check_arch() {
  get_arch=$(arch)
  if [[ ${get_arch} == "x86_64" ]]; then 
    arch="amd64"
  elif [[ ${get_arch} == "aarch64" ]]; then
    arch="arm64"
  else
    echo -e "${Error} go-cqhttp This kernel version is not supported(${get_arch})..." && exit 1
  fi
}

Start_zhenxun_bot() {
    check_installed_zhenxun_status
    check_pid_zhenxun
    [[ -n ${PID} ]] && echo -e "${Error} zhenxun_bot is running, please check !" && exit 1
    cd ${WORK_DIR}/zhenxun_bot
    nohup ${python_v} bot.py >> zhenxun_bot.log 2>&1 &
    echo -e "${Info} zhenxun_bot Start running..."
}

Stop_zhenxun_bot() {
    check_installed_zhenxun_status
    check_pid_zhenxun
    [[ -z ${PID} ]] && echo -e "${Error} zhenxun_bot Not running, please check !" && exit 1
    kill -9 ${PID}
    echo -e "${Info} zhenxun_bot Stopped running..."
}

Restart_zhenxun_bot() {
    Stop_zhenxun_bot
    Start_zhenxun_bot
}

View_zhenxun_log() {
    tail -f -n 100 ${WORK_DIR}/zhenxun_bot/zhenxun_bot.log
}

Set_config_zhenxun() {
    vim ${WORK_DIR}/zhenxun_bot/configs/config.yaml
}

Start_cqhttp() {
    check_installed_cqhttp_status
    check_pid_cqhttp
    [[ -n ${PID} ]] && echo -e "${Error} go-cqhttp is running, please check !" && exit 1
    cd ${WORK_DIR}/go-cqhttp
    nohup ./go-cqhttp -faststart >> go-cqhttp.log 2>&1 &
    echo -e "${Info} go-cqhttp Start running..."
    echo -e "${info} Please scan the QR code to log in to bot, and use Ctrl + C to log out after the bot account has been logged in !"
    sleep 2
}

Stop_cqhttp() {
    check_installed_cqhttp_status
    check_pid_cqhttp
    [[ -z ${PID} ]] && echo -e "${Error} cqhttp Not running, please check !" && exit 1
    kill -9 ${PID}
    echo -e "${Info} go-cqhttp Stop running..."
}

Restart_cqhttp() {
    Stop_cqhttp
    Start_cqhttp
}

View_cqhttp_log() {
    tail -f -n 100 ${WORK_DIR}/go-cqhttp/go-cqhttp.log
}

Set_config_cqhttp() {
    vim ${WORK_DIR}/go-cqhttp/config.yml
}


Set_config_zhenxun() {
    vim ${WORK_DIR}/zhenxun_bot/configs/config.yaml
}

Exit_cqhttp() {
    cd ${WORK_DIR}/go-cqhttp
    rm -f session.token
    echo -e "${Info} go-cqhttp Account is logged out..."
    Stop_cqhttp
    sleep 3
    menu_cqhttp
}

Uninstall_All() {
  echo -e "${Tip} Is zhenxun_bot and go-cqhttp completely uninstalled?"
  read -erp "Please select [y/n], the default is n:" uninstall_check
  [[ -z "${uninstall_check}" ]] && uninstall_check='n'
  if [[ ${uninstall_check} == 'y' ]]; then
    cd ${WORK_DIR}
    check_pid_zhenxun
    [[ -z ${PID} ]] || kill -9 ${PID}
    echo -e "${Info} Start Uninstall zhenxun_bot..."
    rm -rf zhenxun_bot || echo -e "${Error} zhenxun_bot Uninstallation failed!"
    check_pid_cqhttp
    [[ -z ${PID} ]] || kill -9 ${PID}
    echo -e "${Info} Start Uninstall go-cqhttp..."
    rm -rf go-cqhttp || echo -e "${Error} go-cqhttp Uninstallation failed!"
    echo -e "${Info} Thank you for using ZhenxunBot and I look forward to meeting you again!"
  fi
  echo -e "${Info} Operation cancelled..." && menu_zhenxun
}

Update_Shell(){
    echo -e "${Info} Start updating install.sh"
    bak_dir_name="sh_bak/"
    bak_file_name="${bak_dir_name}install.`date +%Y%m%d%H%M%s`.sh"
    if [[ ! -d ${bak_dir_name} ]]; then
        sudo mkdir -p ${bak_dir_name}
        echo -e "${Info} Create backup folder${bak_dir_name}"
    fi
    wget ${update_shell_url} -O install.sh.new
    sudo cp -f install.sh ${bak_file_name}
    echo -e "${Info} Back up the original install.sh as ${bak_file_name}"
    sudo mv -f install.sh.new install.sh
    echo -e "${Info} install.sh update completed, please restart"
    exit 0
}

cqhttp_echooff(){
  case "$cqhttp_echooff_num" in
  0)
    Update_Shell
    ;;
  1)
    Start_cqhttp
    ;;
  2)
    Stop_cqhttp
    ;;
  3)
    Restart_cqhttp
    ;;
  4)
    Set_config_cqhttp
    ;;
  5)
    View_cqhttp_log
    ;;  
  6)
    Exit_cqhttp
    ;;
  10)
    menu_zhenxun
    ;;
  *)
    echo "Plz input the correct number or\$2 [0-6,10]"
    echo -e "
      ${Green_font_prefix} 0.${Font_color_suffix} update script
      ${Green_font_prefix} 1.${Font_color_suffix} start go-cqhttp
      ${Green_font_prefix} 2.${Font_color_suffix} end go-cqhttp
      ${Green_font_prefix} 3.${Font_color_suffix} restart go-cqhttp
      ${Green_font_prefix} 4.${Font_color_suffix} edit go-cqhttp profile
      ${Green_font_prefix} 5.${Font_color_suffix} view go-cqhttp log
      ${Green_font_prefix} 6.${Font_color_suffix} exit go-cqhttp account
      ${Green_font_prefix}10.${Font_color_suffix} switch zhenxun_bot menu" && echo
    ;;
  esac
}

zhenxun_bot_echooff(){
  case "$zhenxun_echooff_num" in
    0)
      Update_Shell
      ;;
    1)
      Start_zhenxun_bot
      ;;
    2)
      Stop_zhenxun_bot
      ;;
    3)
      Restart_zhenxun_bot
      ;;
    4)
      Set_config_zhenxun
      ;;
    5)
      View_zhenxun_log
      ;;
    6)
      Uninstall_All
      ;;
    10)
      menu_cqhttp
      ;;
    *)
      echo "Plz input the correct number or\$2 [0-6,10]"
      ;;
    esac
}

menu_cqhttp() {
  echo && echo -e "  go-cqhttp install control script ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- Sakura | github.com/AkashiCoin --
 ${Green_font_prefix} 0.${Font_color_suffix} update script
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} start go-cqhttp
 ${Green_font_prefix} 2.${Font_color_suffix} end go-cqhttp
 ${Green_font_prefix} 3.${Font_color_suffix} restart go-cqhttp
————————————
 ${Green_font_prefix} 4.${Font_color_suffix} edit go-cqhttp profile
 ${Green_font_prefix} 5.${Font_color_suffix} view go-cqhttp log
————————————
 ${Green_font_prefix} 6.${Font_color_suffix} exit go-cqhttp account
 ${Green_font_prefix}10.${Font_color_suffix} switch zhenxun_bot menu" && echo
  if [[ -e "${WORK_DIR}/go-cqhttp/go-cqhttp" ]]; then
    check_pid_cqhttp
    if [[ -n "${PID}" ]]; then
      echo -e " now status: go-cqhttp ${Green_font_prefix}already installed${Font_color_suffix} and ${Green_font_prefix}running${Font_color_suffix}"
    else
      echo -e " now status: go-cqhttp ${Green_font_prefix}already installed${Font_color_suffix} but ${Red_font_prefix}not running${Font_color_suffix}"
    fi
  else
    if [[ -e "${file}/go-cqhttp/go-cqhttp" ]]; then
      check_pid_cqhttp
      if [[ -n "${PID}" ]]; then
        echo -e " now status: go-cqhttp ${Green_font_prefix}already installed${Font_color_suffix} and ${Green_font_prefix}running${Font_color_suffix}"
      else
        echo -e " now status: go-cqhttp ${Green_font_prefix}already installed${Font_color_suffix} but ${Red_font_prefix}not running${Font_color_suffix}"
      fi
    else
      echo -e " now status: go-cqhttp ${Red_font_prefix}not install${Font_color_suffix}"
    fi
  fi
  echo
  read -erp " Input NUM[0-10]:" cqhttp_echooff_num
  cqhttp_echooff
}

menu_zhenxun() {
  echo && echo -e "  zhenxun_bot install control script ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- Sakura | github.com/AkashiCoin --
 ${Green_font_prefix} 0.${Font_color_suffix} update script
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} start zhenxun_bot
 ${Green_font_prefix} 2.${Font_color_suffix} end zhenxun_bot
 ${Green_font_prefix} 3.${Font_color_suffix} restart zhenxun_bot
————————————
 ${Green_font_prefix} 4.${Font_color_suffix} edit zhenxun_bot profile
 ${Green_font_prefix} 5.${Font_color_suffix} view zhenxun_bot log
————————————
 ${Green_font_prefix} 6.${Font_color_suffix} Uninstall zhenxun_bot + go-cqhttp
 ${Green_font_prefix} 10.${Font_color_suffix} switch go-cqhttp menu" && echo
  if [[ -e "${WORK_DIR}/zhenxun_bot/bot.py" ]]; then
    check_pid_zhenxun
    if [[ -n "${PID}" ]]; then
      echo -e " now status: zhenxun_bot ${Green_font_prefix}already installed${Font_color_suffix} and ${Green_font_prefix}running${Font_color_suffix}"
    else
      echo -e " now status: zhenxun_bot ${Green_font_prefix}already installed${Font_color_suffix} but ${Red_font_prefix}not running${Font_color_suffix}"
    fi
  else
    if [[ -e "${file}/zhenxun_bot/bot.py" ]]; then
      check_pid_zhenxun
      if [[ -n "${PID}" ]]; then
        echo -e " now status: zhenxun_bot ${Green_font_prefix}already installed${Font_color_suffix} and ${Green_font_prefix}running${Font_color_suffix}"
      else
        echo -e " now status: zhenxun_bot ${Green_font_prefix}already installed${Font_color_suffix} but ${Red_font_prefix}not running${Font_color_suffix}"
      fi
    else
      echo -e " now status: zhenxun_bot ${Red_font_prefix}not install${Font_color_suffix}"
    fi
  fi
  echo
  read -erp " Input NUM[0-10]:" zhenxun_echooff_num
  zhenxun_bot_echooff
}

# main process
ext_1=$1
ext_2=$2
# echo "$1 $2"
if [ "$ext_1" != "" ];then
  if [ "$ext_1" == "1" ];then
    echo -e "${Info} zhenxun_bot CLI"
    zhenxun_echooff_num=$ext_2
    zhenxun_bot_echooff
  elif [ "$ext_1" == "2" ];then
    echo -e "${Info} cqhttp CLI"
    cqhttp_echooff_num=$ext_2
    cqhttp_echooff
  else
    echo 'Plz enter the correct\$1 [1-2]'
    echo '1.zhenxun_bot'
    echo '2.cqhttp'
    exit 0
  fi
else
  menu_zhenxun
fi
