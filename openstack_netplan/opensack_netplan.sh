#!/bin/bash

# Verifica se todos os argumentos foram passados corretamente
if [ "$#" -ne 3 ]; then
    echo "Uso: $0 <IPv4> <Caminho_Chave_SSH> <IPv6>"
    exit 1
fi

# Atribui os argumentos a variáveis locais
IPV4="$1"                # IPv4 da instância para conexão SSH
CHAVE_SSH="$2"           # Caminho completo da chave SSH para autenticação
IPV6="$3"                # IPv6 fixo a ser configurado na instância

echo "Iniciando conexão SSH para o servidor remoto..."
# Conecta-se ao servidor remoto e configura o Netplan
ssh -o StrictHostKeyChecking=no -t -i "$CHAVE_SSH" ubuntu@$IPV4 << EOF
  set -e  # Faz o script parar em caso de erro

  echo "Criando backup do Netplan..."
  sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.old

  echo "Extraindo MAC address da interface ens4..."
MAC=\$(sudo grep -A 5 'ens4:' /etc/netplan/50-cloud-init.yaml | sudo grep -oP 'macaddress: "\K[^"]+' | head -n 1)

if [ -z "\$MAC" ]; then
  echo "Erro: Não foi possível extrair o MAC address. Abortando."
  exit 1
fi

echo "MAC Address extraído: \$MAC"

  echo "Atualizando configuração do Netplan..."
  sudo tee /etc/netplan/50-cloud-init.yaml > /dev/null << NETPLAN
network:
  version: 2
  ethernets:
    ens4:
      addresses: ['$IPV6/64']
      accept-ra: false
      dhcp4: false
      dhcp6: false
      match:
        macaddress: "\$MAC"
      mtu: 1500
      set-name: ens4
      routes:
        - to: default
          via: <network>
      nameservers:
        addresses: ['<ipv61>','<ipv62>']
    ens3:
      dhcp4: true
      mtu: 1450
NETPLAN

  echo "Aplicando Netplan..."
  sudo netplan apply

  echo "Configuração concluída com sucesso!"
EOF
