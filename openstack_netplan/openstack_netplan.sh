#!/bin/bash

## Uso: ./configura_rede.sh <IPv4> <USUARIO> <IPv6>
## Exemplo: ./configura_rede.sh 10.0.0.2 ubuntu 2804:xxxx::1234

if [ "$#" -ne 3 ]; then
    echo "Uso: $0 <IPv4> <USUARIO> <IPv6>"
    exit 1
fi

IPV4="$1"
USUARIO="$2"
IPV6="$3"

# 🔹 Valores fixos do ambiente (ajusta conforme necessário)
GATEWAY="coloque o Gateway"
DNS1="coloque o dns"
DNS2="coloque o dns"

echo "Iniciando conexão SSH para $USUARIO@$IPV4 ..."

ssh -o StrictHostKeyChecking=no -t "$USUARIO@$IPV4" << EOF
  set -e

  TIMESTAMP=\$(date +"%Y%m%d_%H%M%S")

  echo "Verificando se já existe /etc/netplan/01-netcfg.yaml ..."
  if [ -f /etc/netplan/01-netcfg.yaml ]; then
    echo "Arquivo /etc/netplan/01-netcfg.yaml já existe! Abortando para evitar sobrescrita."
    exit 1
  fi

  echo "Procurando arquivo netplan..."
  if [ -f /etc/netplan/50-cloud-init.yaml ]; then
    ORIG_FILE="/etc/netplan/50-cloud-init.yaml"
  else
    echo "Nenhum arquivo netplan encontrado!"
    exit 1
  fi

  echo "Renomeando arquivo original..."
  sudo mv "\$ORIG_FILE" "\${ORIG_FILE}.old_\$TIMESTAMP"

  echo "Pegando MAC da interface ens4..."
  MAC=\$(ip link show ens4 | awk '/ether/ {print \$2}')
  if [ -z "\$MAC" ]; then
    echo "Erro: não consegui pegar o MAC da ens4"
    exit 1
  fi
  echo "MAC encontrado: \$MAC"

  echo "Gerando novo /etc/netplan/01-netcfg.yaml ..."
  sudo awk -v ipv6="$IPV6" -v mac="\$MAC" -v gw="$GATEWAY" -v dns1="$DNS1" -v dns2="$DNS2" '
    /^ *ens4:/ {
      print "    ens4:";
      print "      addresses: [\"" ipv6 "/64\"]";
      print "      dhcp4: false";
      print "      dhcp6: false";
      print "      accept-ra: false";
      print "      match:";
      print "        macaddress: \"" mac "\"";
      print "      mtu: 1450";
      print "      routes:";
      print "        - to: default";
      print "          via: " gw;
      print "      nameservers:";
      print "        addresses: [\"" dns1 "\",\"" dns2 "\"]";
      skip=1; next
    }
    skip && /^[^ ]/ { skip=0 }
    !skip { print }
  ' "\${ORIG_FILE}.old_\$TIMESTAMP" | sudo tee /etc/netplan/01-netcfg.yaml > /dev/null

  echo "Ajustando permissões do netplan..."
  sudo chown root:root /etc/netplan/01-netcfg.yaml
  sudo chmod 600 /etc/netplan/01-netcfg.yaml

  echo "Desativando network config do cloud-init..."
  sudo mkdir -p /etc/cloud/cloud.cfg.d
  echo "network:
  config: disabled" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg > /dev/null

  echo "Aplicando netplan..."
  sudo netplan apply

  echo "Rede configurada com sucesso!"
EOF
