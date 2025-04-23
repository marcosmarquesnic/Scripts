#!/usr/bin/env python3

import subprocess
import sys
import datetime
import re

if len(sys.argv) != 2:
    print("Uso: python troubleshoot.py <host>")
    sys.exit(1)

host = sys.argv[1]
print("\nSegue troubleshooting do host:", host)
print("\nData:", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
print("\n" + "=" * 100)

def run_cmd(title, command):
    print(f"# {title}")
    print(f"Comando: {' '.join(command)}\n")
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT, text=True)
        print(output)
        return output
    except subprocess.CalledProcessError as e:
        print(e.output)
        return e.output

# Statuses para o resumo
status = {
    "HOST": False,
    "PINGv4": False,
    "PINGv6": False,
    "MTRv4": False,
    "MTRv6": False,
    "NMAPv4": "",
    "NMAPv6": ""
}

# HOST
out = run_cmd("HOST", ["host", host])
if "not found" not in out and "NXDOMAIN" not in out:
    print("\033[1;32m✅ Host resolvido\033[0m")
    status["HOST"] = True
else:
    print("\033[1;31m❌ Host não resolvido\033[0m")

print("=" * 100)

# PING IPv4
out = run_cmd("PING", ["ping", "-c", "5", host])
if "bytes from" in out:
    match = re.findall(r'time=(\d+\.\d+)', out)
    if match:
        avg = round(sum(map(float, match)) / len(match), 2)
        print(f"\033[1;32m✅ Ping IPv4 respondeu - Latência média: {avg} ms\033[0m")
        status["PINGv4"] = True
else:
    print("\033[1;31m❌ Ping IPv4 sem resposta\033[0m")

print("=" * 100)

# PING IPv6
out = run_cmd("PINGv6", ["ping6", "-c", "5", host])
if "bytes from" in out:
    print("\033[1;32m✅ Ping IPv6 respondeu\033[0m")
    status["PINGv6"] = True
else:
    print("\033[1;33m⚠️  Ping IPv6 sem resposta\033[0m")

print("=" * 100)

# MTR v4
out = run_cmd("TRACE v4", ["mtr", "-4", "-rn", host, "--report", "--report-cycles", "5"])
if "HOST" in out:
    print("\033[1;36m📍 MTR IPv4 executado com sucesso\033[0m")
    status["MTRv4"] = True
else:
    print("\033[1;31m❌ MTR IPv4 falhou\033[0m")

print("=" * 100)

# MTR v6
out = run_cmd("TRACE v6", ["mtr", "-6", "-rn", host, "--report", "--report-cycles", "5"])
if "HOST" in out:
    print("\033[1;36m📍 MTR IPv6 executado com sucesso\033[0m")
    status["MTRv6"] = True
else:
    print("\033[1;33m⚠️  MTR IPv6 pode não ter funcionado\033[0m")

print("=" * 100)

# NMAP v4
out = run_cmd("NMAP", ["nmap", "-p", "22,53,80,443,8080", "-Pn", host])
ports = re.findall(r'^(\d+)/tcp\s+open', out, re.M)
if ports:
    status["NMAPv4"] = ",".join(ports)
    print(f"\033[1;32m✅ Portas IPv4 abertas: {status['NMAPv4']}\033[0m")
else:
    print("\033[1;33m⚠️  Nenhuma porta IPv4 aberta detectada\033[0m")

print("=" * 100)

# NMAP v6
out = run_cmd("NMAP v6", ["nmap", "-6", "-p", "22,53,80,443,8080", "-Pn", host])
ports = re.findall(r'^(\d+)/tcp\s+open', out, re.M)
if ports:
    status["NMAPv6"] = ",".join(ports)
    print(f"\033[1;32m✅ Portas IPv6 abertas: {status['NMAPv6']}\033[0m")
else:
    print("\033[1;33m⚠️  Nenhuma porta IPv6 aberta detectada\033[0m")

print("=" * 100)

# RESUMO FINAL
print("\n========================= RESUMO FINAL =========================")
print("✅ Host resolvido" if status["HOST"] else "❌ Host não resolvido")
print("✅ IPv4 responde ping" if status["PINGv4"] else "❌ IPv4 sem resposta")
print("✅ IPv6 responde ping" if status["PINGv6"] else "⚠️  IPv6 sem resposta")
print("✅ MTR IPv4 OK" if status["MTRv4"] else "❌ MTR IPv4 falhou")
print("✅ MTR IPv6 OK" if status["MTRv6"] else "⚠️  MTR IPv6 falhou ou parcial")
print("✅ Portas IPv4 abertas: " + status["NMAPv4"] if status["NMAPv4"] else "⚠️  Nenhuma porta IPv4 aberta")
print("✅ Portas IPv6 abertas: " + status["NMAPv6"] if status["NMAPv6"] else "⚠️  Nenhuma porta IPv6 aberta")
print("=" * 60 + "\n")
