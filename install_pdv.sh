#!/bin/bash

#CRIADO POR: MATHEUS ANTUNES
#Script para instalação e configurções dos PDVs autosystem e merito

#Ultima atualização: 15/06/23 - Atualização do script da imagem; Alteração de porta agora está no install_pdv; Melhoria na instalação da VPN; Melhoria na leitura do codigo

## url para wget:
    vpn='http://192.168.0.29/sitef/gsclient_ubuntu_x64.zip'
    brother=''
    ricoh=''
    teamviewer='http://192.168.0.29/instaladores/teamviewer_15.41.7_amd64.deb'
    asinstall='http://192.168.0.29/autosystem/as_install.sh.gz'
    jposto='http://192.168.0.29/jposto.zip'
    autosystem='http://192.168.0.29/autosystem/autosystem3_33193.zip'
    autosystem60='http://192.168.0.29/autosystem/autosystem3_33160.zip'

## comandos
    awget="wget -P /usr/src/"

## funções de configurações
    
    #Netplan
    function confNetplan(){
        echo "# This is the network config written by "subiquity"
network:
 ethernets:
  eth0:
   addresses:
   - $ip/24
   gateway4: $mgateway
   nameservers:
     addresses:
     - $mdns
     search:
      - buffon.com.br
 version: 2" > /etc/netplan/00-installer-config.yaml
    }

    function confNetplanDHCP(){
echo "# This is the network config written by 'subiquity'
network:
  version: 2
  renderer: networkd
  ethernets:
          eth0:
                  dhcp4: yes"
    }

    function saveMac(){
        echo "POSTO:$posto PDV:$pdv" >> /var/tmp/mac_maquinas_novas.txt
        ip link show | grep -o 'link/ether .*' | awk '{print $2}' >> /var/tmp/mac_maquinas_novas.txt
        echo "---" >> /var/tmp/mac_maquinas_novas.txt
        echo " " >> /var/tmp/mac_maquinas_novas.txt

        sshpass -p '#cb%aaa29@;' scp -P 22 /var/tmp/mac_maquinas_novas.txt root@192.168.0.29:/var/www/html/
    }

    #sshd
    function confSSHD(){
        echo "
        # This is the sshd server system-wide configuration file.  See
        # sshd_config(5) for more information.

        # This sshd was compiled with PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

        # The strategy used for options in the default sshd_config shipped with
        # OpenSSH is to specify options with their default value where
        # possible, but leave them commented.  Uncommented options override the
        # default value.

        Include /etc/ssh/sshd_config.d/*.conf

        Port 221$pdv
        #AddressFamily any
        #ListenAddress 0.0.0.0
        #ListenAddress ::

        #HostKey /etc/ssh/ssh_host_rsa_key
        #HostKey /etc/ssh/ssh_host_ecdsa_key
        #HostKey /etc/ssh/ssh_host_ed25519_key

        # Ciphers and keying
        #RekeyLimit default none

        # Logging
        #SyslogFacility AUTH
        #LogLevel INFO

        # Authentication:

        #LoginGraceTime 2m
        PermitRootLogin yes
        #StrictModes yes
        #MaxAuthTries 6
        #MaxSessions 10

        #PubkeyAuthentication yes

        # Expect .ssh/authorized_keys2 to be disregarded by default in future.
        #AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2

        #AuthorizedPrincipalsFile none

        #AuthorizedKeysCommand none
        #AuthorizedKeysCommandUser nobody

        # For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
        #HostbasedAuthentication no
        # Change to yes if you don't trust ~/.ssh/known_hosts for
        # HostbasedAuthentication
        #IgnoreUserKnownHosts no
        # Don't read the user's ~/.rhosts and ~/.shosts files
        #IgnoreRhosts yes

        # To disable tunneled clear text passwords, change to no here!
        #PasswordAuthentication yes
        #PermitEmptyPasswords no

        # Change to yes to enable challenge-response passwords (beware issues with
        # some PAM modules and threads)
        KbdInteractiveAuthentication no

        # Kerberos options
        #KerberosAuthentication no
        #KerberosOrLocalPasswd yes
        #KerberosTicketCleanup yes
        #KerberosGetAFSToken no

        # GSSAPI options
        #GSSAPIAuthentication no
        #GSSAPICleanupCredentials yes
        #GSSAPIStrictAcceptorCheck yes
        #GSSAPIKeyExchange no

        # Set this to 'yes' to enable PAM authentication, account processing,
        # and session processing. If this is enabled, PAM authentication will
        # be allowed through the KbdInteractiveAuthentication and
        # PasswordAuthentication.  Depending on your PAM configuration,
        # PAM authentication via KbdInteractiveAuthentication may bypass
        # the setting of "PermitRootLogin without-password".
        # If you just want the PAM account and session checks to run without
        # PAM authentication, then enable this but set PasswordAuthentication
        # and KbdInteractiveAuthentication to 'no'.
        UsePAM yes

        #AllowAgentForwarding yes
        #AllowTcpForwarding yes
        #GatewayPorts no
        X11Forwarding yes
        #X11DisplayOffset 10
        #X11UseLocalhost yes
        #PermitTTY yes
        PrintMotd no
        #PrintLastLog yes
        #TCPKeepAlive yes
        #PermitUserEnvironment no
        #Compression delayed
        #ClientAliveInterval 0
        #ClientAliveCountMax 3
        #UseDNS no
        #PidFile /run/sshd.pid
        #MaxStartups 10:30:100
        #PermitTunnel no
        #ChrootDirectory none
        #VersionAddendum none

        # no default banner path
        #Banner none

        # Allow client to pass locale environment variables
        AcceptEnv LANG LC_*

        # override default of no subsystems
        Subsystem sftp  /usr/lib/openssh/sftp-server

        # Example of overriding settings on a per-user basis
        #Match User anoncvs
        #       X11Forwarding no
        #       AllowTcpForwarding no
        #       PermitTTY no
        #       ForceCommand cvs server
        PasswordAuthentication yes
        " > /etc/ssh/sshd_config
            }


## funções de instalações
    
    #teamviewer
    function instTeamviewer(){
        shopt -s nullglob
        
        if ! timeout 60s ls teamviewer*.deb 1> /dev/null 2>&1; then
            echo "Nenhum pacote do TeamViewer encontrado."
            return 1
        fi
        
        sudo dpkg -i teamviewer*.deb
        sudo apt -f install -y
        sudo dpkg -i teamviewer*.deb
        shopt -u nullglob
    }

    
    #anydeskt
    function instAnydesk(){
        wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
        echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
        apt update
        apt install anydesk -y
    }

    #vpn
    function instVpn(){
        $awget $vpn
        rm -rf /usr/gsurf
        cd /
        mkdir gsurf
        cd /usr/src
        unzip gsclient_ubuntu_x64.zip
        cd gsclient_ubuntu_x64
        mv instalador serverSSL /gsurf
        cp CliSiTef.ini /usr/local/autosystem3
        cp CliSiTef.ini /usr/lib
        mv libGSurfRSA.so /usr/lib
        cd clisitef-7.0.117.42.r1-Producao-Linux64
        mv * /usr/lib
        cd /gsurf
        chmod 777 *

        while true; do
        echo "Rodar instalador da VPN?"
        echo " "
        echo "1. Sim"
        echo "2. Não"    
        read opvpn

        case $opvpn in
            1)
            ./instalador
            systemctl daemon-reload
            systemctl enable libssl.service
            systemctl start libssl.service
            telnet 127.0.0.1 4096
            break
            ;;

            2) 
            break
            ;;
        esac
        done
    }

## funções de atualiazações    
    
    #merito
    function attMerito(){
        cd /opt
        curl -O http://192.168.0.29/jposto.zip
        unzip jposto.zip
        echo "#Fri Feb 24 08:08:34 BRT 2023
BD=jposto
IP=10.12.$posto.254
SENHA=0x6fy0x78y0x6by0x62y0x68y0x6ey
EMPRESA=001
UNIDADE=$posto
USUARIO=0x70y0x6fy0x73y0x74y0x67y0x72y0x65y0x73y" > /opt/jposto/bin/com/resources/conf.properties
    }

#inicio do script
while true; do
    echo "Digite o posto"

    read posto
    echo " "

    echo "Digite o pdv"

    read pdv
    echo " "
    sleep 1

    clear
    echo "Confirme as informações:"
    echo "Posto: $posto"
    echo "PDV: $pdv"
    echo " "
    echo " "
    
    sleep 1
    echo "1. Confirmar"
    echo "2. Corrigir"

    read opcao
    clear

    case $opcao in
        1)       
        #Teamviewer
        echo "instalando teamviewer"
        sleep 2
            cd /usr/src
            $awget $teamviewer
            instTeamviewer
                clear
            sleep 2
        echo "Teamviewer instalado"
        sleep 2
                clear

        #Anydesk
        echo "instalando Anydesk"
        sleep 2
            instAnydesk
                clear
        echo "Anydesk instalado"
        sleep 2
                clear

        #Config rede final
        ip="10.12.$posto.1$pdv"
        mgateway="10.12.$posto.254"
        mdns="10.12.$posto.254"       

        #Ajuste de netplan 
        echo "configurando netplan"
        sleep 1
        echo "O posto está rodando na blockbit?"
        echo "1. Sim"
        echo "2. Não"
        read BlockOption

        if [ "BlockOption" eq 1]; then
            confNetplanDHCP
            saveMac
            clear
            echo "netplan configurado"
        else
            confNetplan
            clear
            echo "netplan configurado"
            echo " "
            sleep 2
        fi

        clear

        #Ajuste de ssh 
        echo "configurando ssh"
        sleep 2
            confSSHD
                clear
        echo "ssh configurado"
        echo " "
        sleep 2
                clear

        #Ajuste anydesk final
        echo "Ajuste senha do anydesk"
        sleep 2    
            anydesk-global-settings
        echo " "
        sleep 2
        clear

        #VPN
        echo "Instalando VPN"
        sleep 2
            instVpn
        echo "VPN finalizada"
        sleep 2
        clear

            #Atualizando sistemas
            while true; do
            
            echo "Atualizando o sistema do PDV"
            echo " "
            sleep 1
            echo "1. Autosystem"
            echo "2. Merito"

            read system

                case $system in
                    1)  
                        #Instruções para config final
                        echo " "
                        echo " "
                        echo "INSTRUÇÕES PARA CONFIGURAÇÕES FINAIS"
                        echo " "
                        sleep 1
                        echo "COMO USER, EXECUTE:"
                        echo " " 
                        sleep 1
                        echo "as_config:"
                        echo "PBUFQxxx (final do cnpj)"
                        echo "SE000xxx (posto + n do pdv)"
                        echo " "
                        sleep 1
                        echo "Configurar teamviewer"
                        echo "Reinicar a maquina"
                        break 2
                        ;;

                        2)  
                        echo "Baixando jposto"
                        sleep 1
                        attMerito
                        clear
                        echo "Instalação finalizada"
                        break 2
                        ;;
                esac
            done
            ;;            


        2)
            echo "Corrigindo informações"
            echo " "
            ;;
    esac
done




