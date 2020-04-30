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
    echo " 5.[$opt5] Add useful aliases"
    echo " 0.    START"
    echo "#################################\n"
    echo "You can un/check choosing the task number"
    echo "0 to start"
    read -n 1 -p "[0-9] Selection:" menuOpt

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

    echo -e "\n"
    read -p "Write your pass for ${userAdd}: " userPass
    echo -e "${userAdd}:${userPass}" | sudo chpasswd

    echo -e "\n"
    read -n 1 -p "Add user to sudoers.d? (using sudo wont ask for passwd) [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        echo "${userAdd} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/010_${userAdd}-nopasswd
    fi

    echo -e "\n"
    read -n 1 -p "Lock the pi user [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        sudo passwd --lock pi
    fi

    echo -e "\n"
    read -n 1 -p "Lock the root user [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        sudo passwd --lock root
    fi

    #echo -e "\n"
    #echo "Use your new user ${userAdd} as alias for root?"
    #echo "This action will add to /etc/aliases:"
    #echo "root: ${userAdd},root"
    #echo "${userAdd}: your@email.com"
    #read -n 1 -p "Recomended for example to receive events, send/receive emails etc. [y/n]: " yn
    #if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
    #    read -p "Email to add to /etc/aliases: " emailAliases
    #    echo -e "root: ${userAdd},root \n${userAdd}: ${emailAliases}"
    #    #reload aliases
    #    sudo /usr/bin/newaliases
    #fi

    #echo -e "\n"
    #read -n 1 -p "Continue the script with the new user ${userAdd}? Recomended [y/n]: " yn
    #if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
    #    sudo su $userAdd
    #fi

    delPiUser=0
    echo -e "\n"
    read -n 1 -p "Del user pi? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        read -n 1 -p "Del home pi too? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            if ! [ whoami == "pi" ]; then
                sudo deluser -remove-home pi
            else
                delPiUser=2
                echo -e "\nRunning currently as pi user, pi can't be automatically deleted"
            fi
        else
            if ! [ whoami == "pi" ]; then
                sudo deluser pi
            else
                delPiUser=1
                echo -e "\nRunning currently as pi user, pi can't be automatically deleted"
            fi
        fi
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
    #check if already installed
    if ! [ -x "$(command -v ufw)" ]; then
        sudo apt install ufw
    else
        echo "UFW is already installed!"
    fi

    read -n 1 -p "Want to configure now? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        echo -e "\n"
        read -n 1 -p "Block any incoming? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo ufw default deny incoming
        fi

        echo -e "\n"
        read -n 1 -p "Allow any outgoing? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo ufw default allow outgoing
        fi

        echo -e "\n"
        read -n 1 -p "Allow any from local access (192.168.1.0/24)? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo ufw allow from 192.168.1.0/24
        fi

        echo -e "\n"
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

    echo -e "\n"
    read -n 1 -p "Want to configure docker now? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then

        echo -e "\n"
        read -n 1 -p "Add current user ${USER} to docker group? [y/n]: " yn
        if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            sudo usermod -aG docker $USER
        fi

        if [ "$opt2" == "x" ]; then
            echo -e "\n"
            read -n 1 -p "Add NEW user ${userAdd} to docker group? [y/n]: " yn
            if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                sudo usermod -aG docker ${userAdd}
            fi
        fi
    fi # END install docker

    echo -e "\n"
    read -n 1 -p "Want to install docker-compose? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        echo -e "Installing dependencies\n"
        sudo apt install -y libffi-dev libssl-dev
        sudo apt install -y python3 python3-pip
        sudo apt remove python-configparser

        echo -e "Install docker-compose"
        sudo pip3 install docker-compose
    fi # END docker-compose

    echo -e "\n"
    read -n 1 -p "Want to setup docker containers? [y/n]: " yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then

        #must match folder names in the repo inside docker/
        customContainers[0]="ngixn"
        customContainers[1]="nodered"

        for dockerImage in "${customContainers[@]}"
        do
            echo -e "\n"
            # ${dockerImage^} this print first letter uppercase
            read -n 1 -p "Download ${dockerImage^} custom container? [y/n]: " yn
            echo -e "\n"
            if [[ "$yn" == "y" || "$yn" == "Y" ]]; then

                downloadDockerImage

                echo -e "\n"
                read -n 1 -p "Download ${dockerImage^} custom docker? [y/n]: " yn
                echo -e "\n"
                if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                    docker-compose up -d
                fi

            fi # END downd custom container
        done

    fi     # END docker containers

} # END installDocker

downloadDockerImage() {

    if [ "${dockerImage}" != "" ]; then

        echo -e "\n"
        read -n 1 -p "Do you want to use the current folder? $PWD [y/n]: " yn
        if ! [[ "$yn" == "y" || "$yn" == "Y" ]]; then
            echo -e "\n"
            read -p "/full/path/for/docker/containers ? : " cdTo
            cd cdTo
        fi

        mkdir ${dockerImage} && cd ${dockerImage}
    
        #auto generate the zip from folder
        baseUrl="https://kinolien.github.io/gitzip/?download=https://github.com/GonzaloTorreras/raspberry-pi-setup/tree/master/src/docker/"
        sudo wget -O ${dockerImage}.zip ${baseUrl}${dockerImage} 
        
        unzip ${dockerImage} && rm ${dockerImage}
        echo -e "You can find ${dockerImage} ready"
    fi
    
}


customAliases() {
    echo -e "\n"
    read -n 1 -p "Add aliases to current user $USER [y/n]: " yn
    echo -e "\n"
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        if ! [ -d ~/.bash_aliases_folder ]; then
            mkdir ~/.bash_aliases_folder
        fi
        cd ~/
        downloadAliases
        #fix permissions
        sudo chown $USER:$USER ~/.bash_aliases_folder/

        #reload aliases
        source ~/.bashrc
    fi

    echo -e "\n"
    read -n 1 -p "Add aliases to NEW user ${userAdd} [y/n]: " yn
    echo -e "\n"
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        if ! [ -d /home/${userAdd}/.bash_aliases_folder ]; then
            sudo mkdir /home/${userAdd}/.bash_aliases_folder
        fi
        cd /home/${userAdd}/
        downloadAliases

        #fix permissions
        sudo chown ${userAdd}:${userAdd} /home/${userAdd}/.bash_aliases_folder/
    fi

} # END customAliases

downloadAliases() {
    # Add a call to the loader in .bashrc
    echo "# Custom aliases" >>.bashrc
    echo "if [ -d ~/.bash_aliases_folder ]; then" >>.bashrc
    echo "  . ~/.bash_aliases_folder/loader" >>.bashrc
    echo "fi" >>.bashrc
    echo "# END custom aliases" >>.bashrc

    # using sudo from here in case we are in home ${userAdd} with pi
    cd .bash_aliases_folder

    # -O to force overwrite, but not for generated which could contain already extra customs -in case you re-run
    sudo wget -O loader https://raw.githubusercontent.com/GonzaloTorreras/raspberry-pi-setup/master/src/.bash_aliases_folder/loader && sudo chmod +x loader
    sudo wget -O common https://raw.githubusercontent.com/GonzaloTorreras/raspberry-pi-setup/master/src/.bash_aliases_folder/common && sudo chmod +x common
    sudo wget -O nginx https://raw.githubusercontent.com/GonzaloTorreras/raspberry-pi-setup/master/src/.bash_aliases_folder/nginx && sudo chmod +x nginx
    sudo wget -O mysql https://raw.githubusercontent.com/GonzaloTorreras/raspberry-pi-setup/master/src/.bash_aliases_folder/mysql && sudo chmod +x mysql

    sudo wget https://raw.githubusercontent.com/GonzaloTorreras/raspberry-pi-setup/master/src/.bash_aliases_folder/generated && sudo chmod +x generated

} # END downloadAliases

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

if [ "$opt5" == "x" ]; then
    customAliases
    echo -e "\n"
fi

if [ delPiUser ]; then
    echo -e "pi user, couldn't be deleted, probably because its running this same shell or a different process"
    echo -e "close any process including this sessions and login with your new user"
    echo -e "from there exec:"

    if [ delPiUser == 2 ]; then
        echo "sudo deluser -remove-home pi"
    else
        echo "sudo deluser pi"
    fi

fi
exit 0
