# ZSH_INSTALL.sh
  
  这个是ZSH自动安装脚本，可以使用命令一键安装
  
  ```bash <(curl -s -L "https://raw.githubusercontent.com/Kurehava/SHELL_Script/main/ZSH/ZSH_INSTALL.sh")```

# Sizuku_double_line.zsh-theme

  这个是自制的ZSH主题，需要先安装好oh-my-zsh
  
 1.```wget "https://raw.githubusercontent.com/Kurehava/SHELL_Script/main/ZSH/Sizuku_double_line.zsh-theme" -O "$(echo ~)/.oh-my-zsh/themes/Sizuku_double_line.zsh-theme"```
 
 2.```sed -i 's:ZSH_THEME="robbyrussell":ZSH_THEME="Sizuku_double_line":g' "$(echo ~)/.zshrc"```
