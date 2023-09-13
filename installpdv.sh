#!/bin/bash
            
# utilitarios
    windex="http://192.168.0.29/install_pdv.zip"

# comandos prontos
    curlIndex="curl -O http://192.168.0.29/install_pdv.zip"

# ips
    mgateway='10.100.10.1'
    mdns='192.168.0.5'

#FUNÇÕES
#Rede
function ifconf(){
    local connected=false

    while [ "$connected" = false ]; do
        
        confNetplan
        netplan apply

        if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
            connected=true
            echo " "
            echo "Conexão estabelecida!"
            echo " "
        else 
            echo "Sem conexão"
            echo "Digite 'r' para tentar novamente ou 'm' para ajustar manualmente:"
            read option

            if [ "$option" = "r" ]; then
                echo "Tentando novamente..."
                netplan apply
                sleep 3
            elif [ "$option" = "m" ]; then
                echo "Ajuste a conexão manualmente e reinicie o script."
                vi /etc/netplan/00-installer-config.yaml
                echo "Use a opção 'Tente novamente' para continuar!"
                sleep 1
                netplan apply
                sleep 1
                continue
                echo "use a opção 'r' para aplicar as configurações de rede"
                echo " "
                sleep 2
            else
                echo "Opção inválida. Saindo do script."
                exit 1
            fi
        fi
    done    
}

function redeTry_mtz(){
    if ping -c 1 $mgateway >/dev/null 2>&1; then
        echo "Conectividade de rede disponível."
        echo "Continuando com o script..."
    else
        echo "Digite o ip de instalação"
        read ip
        echo " "
            if [ $ip == "10.100.10.1" ]; then
                echo "IP INVALIDO"
                echo " "
                echo "Tente novamente"
                redeTry_mtz
                return
            fi
        
        echo "Confirme as informações de rede"
        echo " "
        echo "ip: $ip"
        echo "Gateway: $mgateway"
        echo "DNS: $mdns"
        echo "1. Confirmar"
        echo "2. Corrigir"
        read opcao1
        echo " "
        
        case $opcao1 in
            1) 
                ifconf
                ;;
            2) 
                redeTry_mtz
                return
                ;;
        esac
    fi
}

function redeTry_posto(){
    if ping -c  www.google.com >/dev/null 2>&1; then
        echo "Conectividade de rede disponível."
        echo "Continuando com o script..."
    else
        echo "Digite o ip de instalação"
        echo " "
        read ip
            
        ip_part=$(echo "$ip" | cut -d'.' -f3)
        mgateway=10.12.$ip_part.254
        mdns=10.12.$ip_part.254

        echo "Confirme as informações de rede"
        echo " "
        echo "ip: $ip"
        echo "Gateway: $mgateway"
        echo "DNS: $mdns"
        echo " "
        echo "1. Confirmar"
        echo "2. Corrigir"
        read opcao1
        echo " "
        
        case $opcao1 in
            1) 
                ifconf
                ;;
            2) 
                redeTry_posto
                return
                ;;
        esac
    fi
}

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

function unzp(){
    unzip install_pdv.zip
    ./install_pdv.sh
    chmod 777 *
}




#inicio do script
while true; do

clear
echo "Escolha a instalação"
echo " "
echo "1. Estou na matriz"
echo "2. Estou em um posto"
read opcao
sleep 1

case $opcao in
     1)
        clear
        redeTry_mtz
        
        #Index
        echo "Download do script"
        cd /usr/src/
        $curlIndex
        chmod 777 *
        echo " "
        echo "Iniciando script..."
        echo " "
        sleep 2
        unzp
        
        break 2
        ;;
    
    2)
        clear
        redeTry_posto
        
        #Index
        echo "Download do script"
        cd /usr/src/
        $curlIndex
        chmod 777 *
        echo " "
        echo "Iniciando script..."
        echo " "
        sleep 2
        unzp
        
        break 2
        ;;
esac
done
    



