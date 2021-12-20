#!/bin/bash
# export http_proxy="127.0.0.1:871"
# export https_proxy=$http_proxy
# export socks5_proxy="socks5://127.0.0.1:870"
echo "代理设置完毕"
node_install_path="/opt/node-v12.16.1-linux-x64/"

# 安装rclone
installRclone() {
    cd ~
    echo "正在安装rclone..."
    wget https://downloads.rclone.org/v1.57.0/rclone-v1.57.0-linux-amd64.zip
    unzip rclone-v1.57.0-linux-amd64.zip
    mv rclone-v1.57.0-linux-amd64 rclone
    cd rclone
    chmod +x ./rclone
    mv ./rclone /usr/sbin/
    mkdir ~/.config/rclone/;
    echo "[mcserver]
type = dropbox
token = ${RcloneToken}" >> ~/.config/rclone/rclone.conf
}
# 安装环境
installNode() {
    mkdir -p ${node_install_path}
    cd ${node_install_path}
    sleep 3

    # node
    wget https://npm.taobao.org/mirrors/node/v12.16.1/node-v12.16.1-linux-x64.tar.gz

    # Unpack
    echo "Unpacking..."
    echo "> tar -zxf node-v12.16.1-linux-x64.tar.gz"
    tar -zxf node-v12.16.1-linux-x64.tar.gz
    rm -rf node-v12.16.1-linux-x64.tar.gz
    echo "complete."

    sleep 1

    echo "Linking..."
    echo "> ln -s ${node_install_path}/node-v12.16.1-linux-x64/bin/node /usr/bin/node"
    echo "> ln -s ${node_install_path}/node-v12.16.1-linux-x64/bin/node /usr/bin/node"
    rm -rf /usr/bin/node /usr/bin/npm
    ln -s ${node_install_path}/node-v12.16.1-linux-x64/bin/node /usr/bin/node
    ln -s ${node_install_path}/node-v12.16.1-linux-x64/bin/npm /usr/bin/npm
    echo "complete."
}
#安装服务端
installMCSmanager() {
    cd ~
    echo "正在下载管理界面"
    git clone https://github.com/xhuanya/heroku-mcmanager.git "AllCode"
    mv ./AllCode/Manager ./Manager
    rm -rf ./AllCode
}
# 检查服务端是否存在
checkIsInstall() {
    checkServerHas=$(rclone ls mcserver:/ --cache-db-purge)
    if [[ "${checkServerHas}" == *"mcserver/"* ]]; then
        echo "存在"
          rclone copy mcserver:/mcserver ~/Manager/
    else
        echo "不存在"
        installMCSmanager
    fi
}
start() {
    cd ~/Manager/
    npm install

    nohup npm start >./manager.log 2>&1 &
}

autoBak() {
    while [ 1==1 ]; do
        sleep 1h
        rclone copy  ~/Manager/  mcserver:/mcserver
        echo "备份完成"
    done
}

# 安装
installNode
installRclone
checkIsInstall
autoBak
