# 修改新的安装脚本
  1.```WORK_DIR="$(echo ~)/BOT" ```
  
  2.```TMP_DIR="$(mkdir -p $WORK_DIR/TEMP_DIR_NOT_DEL)" ```
  
# 一键安装脚本
  ```bash <(curl -s -L https://raw.githubusercontent.com/zhenxun-org/zhenxun_bot-deploy/master/install.sh)```
  
  注：建议不要直接使用一键安装脚本 先下载到本地修改脚本后再进行安装 否则他会直接安装到```/home```目录下
  
   1. ```wget https://raw.githubusercontent.com/zhenxun-org/zhenxun_bot-deploy/master/install.sh -O "$(pwd)/zhenxun_install.sh"```
  
  or
  
   1. ```curl https://raw.githubusercontent.com/zhenxun-org/zhenxun_bot-deploy/master/install.sh -o "$(pwd)/zhenxun_install.sh"```
  
  then
  
   2. ```sed -i 's:WORK_DIR="/home":WORK_DIR="$(echo ~)/BOT":g' "$(pwd)/zhenxun_install.sh"```
  
   3. ```sed -i 's:TMP_DIR="$(mktemp -d)":TMP_DIR="$(mkdir -p $WORK_DIR/TEMP_DIR_NOT_DEL)":g' "$(pwd)/zhenxun_install.sh"```
  
   4. ```bash "$(pwd)/zhenxun_install.sh"```

# zhenxun_BOT GIRHUB 主页
  https://github.com/HibiKier/zhenxun_bot

# zhenxun_BOT 文档 主页
  https://hibikier.github.io/zhenxun_bot/

# zhenxun_BOT 配置文件以及管理脚本
  https://github.com/Kurehava/memo/tree/main/%E7%BB%AA%E5%B1%B1%E7%9C%9F%E5%AF%BBbot
