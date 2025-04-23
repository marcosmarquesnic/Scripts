#!/bin/bash

# Uso:
# ./troubleshooting.sh <host>

echo ""
echo "Segue troubleshooting do host: $1"
echo ""

# VARIÁVEIS DE STATUS PARA RESUMO
HOST_OK=0
PING_OK=0
PING6_OK=0
MTR4_OK=0
MTR6_OK=0
NMAP4_PORTS=""
NMAP6_PORTS=""

# MOSTRAR DATA
echo -n "Data: "
date
echo ""

# HOST
echo "================================================================================================="
echo "#HOST"
HOST_OUT=$(host $1 2>&1)
echo "$HOST_OUT"

python3 - <<EOF
out = """$HOST_OUT"""
if "not found" in out or "NXDOMAIN" in out:
    print("\033[1;31m❌ Host não resolvido\033[0m")
else:
    print("\033[1;32m✅ Host resolvido\033[0m")
EOF

[[ "$HOST_OUT" != *"not found"* && "$HOST_OUT" != *"NXDOMAIN"* ]] && HOST_OK=1
echo "================================================================================================="

# PING v4
echo "#PING"
PING_OUT=$(ping -c5 $1 2>&1)
echo "$PING_OUT"

python3 - <<EOF
import re
out = """$PING_OUT"""
match = re.search(r'(\d+) received', out)
if match and int(match.group(1)) > 0:
    latencias = [float(x) for x in re.findall(r'time=(\d+\.\d+)', out)]
    media = round(sum(latencias) / len(latencias), 2) if latencias else "-"
    print(f"\033[1;32m✅ IPv4 responde ping - Latência média: {media} ms\033[0m")
else:
    print("\033[1;31m❌ IPv4 não responde ao ping\033[0m")
EOF

[[ "$PING_OUT" == *"bytes from"* ]] && PING_OK=1
echo "================================================================================================="

# PING v6
echo "#PINGv6"
PING6_OUT=$(ping6 -c5 $1 2>&1)
echo "$PING6_OUT"

python3 - <<EOF
import re
out = """$PING6_OUT"""
match = re.search(r'(\d+) received', out)
if match and int(match.group(1)) > 0:
    print("\033[1;32m✅ IPv6 responde ao ping\033[0m")
else:
    print("\033[1;33m⚠️  IPv6 não respondeu\033[0m")
EOF

[[ "$PING6_OUT" == *"bytes from"* ]] && PING6_OK=1
echo "================================================================================================="

# MTR v4
echo "#TRACE v4"
MTR4_OUT=$(mtr -4 -rn $1 --report --report-cycles 5 2>&1)
echo "$MTR4_OUT"

python3 - <<EOF
out = """$MTR4_OUT"""
if "Start" in out or "HOST" in out:
    print("\033[1;36m📍 MTR IPv4 executado com sucesso\033[0m")
else:
    print("\033[1;31m❌ Falha no MTR IPv4\033[0m")
EOF

[[ "$MTR4_OUT" == *"HOST"* ]] && MTR4_OK=1
echo "================================================================================================="

# MTR v6
echo "#TRACE v6"
MTR6_OUT=$(mtr -6 -rn $1 --report --report-cycles 5 2>&1)
echo "$MTR6_OUT"

python3 - <<EOF
out = """$MTR6_OUT"""
if "Start" in out or "HOST" in out:
    print("\033[1;36m📍 MTR IPv6 executado com sucesso\033[0m")
else:
    print("\033[1;33m⚠️  MTR IPv6 pode não ter funcionado\033[0m")
EOF

[[ "$MTR6_OUT" == *"HOST"* ]] && MTR6_OK=1
echo "================================================================================================="

# NMAP v4
echo "#NMAP"
NMAP4_OUT=$(nmap -p 22,53,80,443,8080 -Pn $1 2>&1)
echo "$NMAP4_OUT"

NMAP4_PORTS=$(echo "$NMAP4_OUT" | grep -oP '^\d+/tcp\s+open' | cut -d/ -f1 | tr '\n' ',' | sed 's/,$//')
[[ -n "$NMAP4_PORTS" ]] && echo -e "\033[1;32m✅ Portas IPv4 abertas: $NMAP4_PORTS\033[0m" || echo -e "\033[1;33m⚠️  Nenhuma porta IPv4 aberta detectada\033[0m"
echo "================================================================================================="

# NMAP v6
echo "#NMAP V6"
NMAP6_OUT=$(nmap -6 -p 22,53,80,443,8080 -Pn $1 2>&1)
echo "$NMAP6_OUT"

NMAP6_PORTS=$(echo "$NMAP6_OUT" | grep -oP '^\d+/tcp\s+open' | cut -d/ -f1 | tr '\n' ',' | sed 's/,$//')
[[ -n "$NMAP6_PORTS" ]] && echo -e "\033[1;32m✅ Portas IPv6 abertas: $NMAP6_PORTS\033[0m" || echo -e "\033[1;33m⚠️  Nenhuma porta IPv6 aberta detectada\033[0m"
echo "================================================================================================="

# RESUMO FINAL
echo ""
echo "========================= RESUMO FINAL ========================="
[[ $HOST_OK -eq 1 ]] && echo "✅ Host resolvido" || echo "❌ Host não resolvido"
[[ $PING_OK -eq 1 ]] && echo "✅ IPv4 responde ping" || echo "❌ IPv4 sem resposta"
[[ $PING6_OK -eq 1 ]] && echo "✅ IPv6 responde ping" || echo "⚠️  IPv6 sem resposta"
[[ $MTR4_OK -eq 1 ]] && echo "✅ MTR IPv4 OK" || echo "❌ MTR IPv4 falhou"
[[ $MTR6_OK -eq 1 ]] && echo "✅ MTR IPv6 OK" || echo "⚠️  MTR IPv6 falhou ou parcial"
[[ -n "$NMAP4_PORTS" ]] && echo "✅ Portas IPv4 abertas: $NMAP4_PORTS" || echo "⚠️  Nenhuma porta IPv4 aberta"
[[ -n "$NMAP6_PORTS" ]] && echo "✅ Portas IPv6 abertas: $NMAP6_PORTS" || echo "⚠️  Nenhuma porta IPv6 aberta"
echo "==============================================================="
echo ""
