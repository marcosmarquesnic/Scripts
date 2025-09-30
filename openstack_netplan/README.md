> Este README.md gerado pelo chatGPT 

# Guia rápido – Script de configuração de rede

Este script serve para **configurar a rede de uma VM/servidor** (IPv4 + IPv6) de forma automática.  
Ele faz tudo sozinho via SSH, então você só precisa rodar o comando certo.  

Verifique a documentação no monday de criação de VMs pelo openstack, é necessário para o funcionamento desse script.

---

## 📌 Como usar

1. **Deixe o script executável** (só precisa fazer uma vez):
   ```bash
   chmod +x configura_rede.sh
   ```

2. **Execute o script** passando:
   - O **IPv4** da máquina  
   - O **usuário** para login (ex: `ubuntu`)  
   - O **IPv6** que você quer configurar  

   Exemplo:
   ```bash
   ./configura_rede.sh 10.0.0.2 ubuntu 2804:xxxx::1234
   ```

---

## ⚙️ O que ele faz automaticamente

- Acessa o servidor via SSH.  
- Faz backup do arquivo original do **netplan**.  
- Descobre o **MAC da interface ens4**.  
- Cria um novo arquivo de configuração da rede (`01-netcfg.yaml`).  
- Desativa a configuração de rede automática do **cloud-init**.  
- Aplica as mudanças com `netplan apply`.  

No final, a rede já estará funcionando com os novos dados. ✅  

---

## 📝 O que você precisa ajustar antes

No script, troque os valores abaixo pelos corretos do seu ambiente:

```bash
GATEWAY="<colocar o gateway>"
DNS1="colocar o dns1"
DNS2="colocar o dns2"
```

---

## 🚨 Erros comuns

- **"Nenhum arquivo netplan encontrado!"**  
  → O servidor não tem os arquivos padrão. Verifique o caminho.  

- **"Erro: não consegui pegar o MAC da ens4"**  
  → Talvez a interface da VM não seja `ens4`. Altere no script para a interface correta (`eth0`, `ens3`, etc).  

---

Pronto 🎉  
É só isso: editar os 3 valores fixos, rodar o script e a rede fica configurada.  
