#!/bin/bash

Help() {
    # Display Help
    echo "This script will update your pi and help you on the initial setup."
    echo "Such add a new user, give it sudo without asking for passwd"
    echo "Ask you if you want to delete pi user (or change it passwd)"
    echo "Lock root account"
    echo "Install UFW and configure it"
    echo "Docker & docker-composer and configure it"

}

opt1="x"
opt2="x"
opt3="x"
opt4="x"
opt5="x"

#debug
#set -x
set -e

mainMenu() {
    clear

    echo "#################################"
    echo " pi auto installer:"
    echo " 1.[$opt1] update & upgrade"
    echo " 2.[$opt2] Add new user"
    echo " 3.[$opt3] Install UFW"
    echo " 4.[$opt4] Install docker"
    echo " 5.[$opt5] Add useful aliases for myself"
    echo " 0.    START"
    echo "#################################\n"
    echo "You can un/check choosing the task number"
    echo "0 to start"
    read -n 2 -p "[0-9] Selection:" menuOpt

}

userAdd=0
addUser() {

    read -p "New user:" userAdd
    read -n 1 -p "add $useradd to sudo group? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        sudo /usr/sbin/useradd --groups sudo -m ${userAdd}
    else
        sudo /usr/sbin/useradd -m ${userAdd}
    fi

    read -p "Write your pass for ${userAdd}" userPass
    echo -e "${userAdd}:${userPass}" | sudo chpasswd

    read -n 1 -p "Add user to sudoers.d? (using sudo wont ask for passwd) [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        echo "${userAdd} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/010_${userAdd}-nopasswd
    fi

    read -n 1 -p "Lock the root user [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        sudo passwd --lock root
    fi

    read -n 1 -p "Continue the script with the new user ${userAdd}? Recomended [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        sudo su $userAdd
    fi

    read -n 1 -p "Del user pi? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        read -n 1 -p "Del home pi too? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo deluser -remove-home pi
        else
            sudo deluser pi
        fi
    fi
    
    echo "Use your new user ${userAdd} as alias for root?"
    echo "This action will add to /etc/aliases:"
    echo "root: ${userAdd},root"
    echo "${userAdd}: your@email.com"
    read -n 1 -p "Recomended for example to receive events, send/receive emails etc. [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        read -p "Email to add to /etc/aliases: " emailAliases
        echo -e "root: ${userAdd},root \n${userAdd}: ${emailAliases}"
        #reload aliases
        sudo /usr/bin/newaliases
    fi

    echo -e "\n"
}

#	if [ `id -u` -eq 0 ]
#	then
#		echo "Please start this script without root privileges!"
#		echo "Try again without sudo."
#		exit 1
#	fi

#if ! [ -x "$(command -v docker-compose)" ]; then
#  echo 'Error: docker-compose is not installed.' >&2
#  exit 1
#fi

installUFW() {
    sudo apt install ufw

    read -n 1 -p "Want to configure now? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then

        read -n 1 -p "Block any incoming? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo ufw default deny incoming
        fi

        read -n 1 -p "Allow any outgoing? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo ufw default allow outgoing
        fi

        read -n 1 -p "Allow any from local access (192.168.1.0/24)? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo ufw allow from 192.168.1.0/24
        fi

        read -n 1 -p "Activate UFW? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo ufw enable
        fi
    fi

    echo -e "\n"
}

installDocker() {
    #check if already installed
    if ! [ -x "$(command -v docker)" ]; then
        curl -sSL https://get.docker.com | sh
    else
        echo "Docker already exists!"
    fi

    read -n 1 -p "Want to configure docker now? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        read -n 1 -p "Add current user ${USER} to docker group? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo usermod -aG docker $USER
        fi

        if [ "$opt2" == "x" ]; then
            read -n 1 -p "Add NEW user ${userAdd} to docker group? [y/n]: " yn
            if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                sudo usermod -aG docker ${userAdd}
            fi
        fi

        read -n 1 -p "Want to install docker-compose? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            echo -e "Installing dependencies\n"
            sudo apt install -y libffi-dev libssl-dev
            sudo apt install -y python3 python3-pip
            sudo apt remove python-configparser

            echo -e "Install docker-compose"
            sudo pip3 install docker-compose
        fi

    fi

}

inMenu=1
while [ $inMenu ]; do
    mainMenu

    case $menuOpt in
    0 | 00)
        inMenu=0
        break
        ;;

    1 | 01)
        if [ $opt1 == "x" ]; then
            opt1="-"
        else
            opt1="x"
        fi
        ;;
    2 | 02)
        if [ $opt2 == "x" ]; then
            opt2="-"
        else
            opt2="x"
        fi
        ;;
    3 | 03)
        if [ $opt3 == "x" ]; then
            opt3="-"
        else
            opt3="x"
        fi
        ;;
    4 | 04)
        if [ $opt4 == "x" ]; then
            opt4="-"
        else
            opt4="x"
        fi
        ;;
    5 | 05)
        if [ $opt5 == "x" ]; then
            opt5="-"
        else
            opt5="x"
        fi
        ;;

    *) echo "only the numbered options are valid" ;;
    esac
done

echo -e "\n"

if [ "$opt1" == "x" ]; then
    sudo apt update && sudo apt upgrade -y
    echo -e "\n"
fi

if [ "$opt2" == "x" ]; then
    addUser
fi

if [ "$opt3" == "x" ]; then
    installUFW
    echo -e "\n"
fi

if [ "$opt4" == "x" ]; then
    installDocker
    echo -e "\n"
fi

exit 0
