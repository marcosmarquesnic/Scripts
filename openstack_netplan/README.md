# Configurador Automático de Rede (Netplan + OpenStack)

Este script Bash automatiza a configuração de rede IPv6 estática em uma instância Ubuntu provisionada via OpenStack, utilizando o Netplan. Ele permite que você conecte-se via SSH a uma instância e atualize sua configuração de rede de forma segura e rápida.

## 📋 Pré-requisitos

- A instância deve estar acessível via IPv4.
- A chave SSH para acesso deve estar disponível localmente.
- O Netplan deve estar instalado e ser usado como gerenciador de rede (configuração padrão no Ubuntu 18.04+).

## 🧾 Uso

```bash
./script.sh <IPv4> <Caminho_Chave_SSH> <IPv6>
```

**Exemplo:**

```bash
./script.sh 192.168.0.100 ~/.ssh/minha-chave.pem 2804:14c:abc::1234
```

## 📜 O que o script faz

1. **Valida os argumentos:** Certifica-se de que os três parâmetros obrigatórios foram passados (IPv4, caminho da chave SSH e IPv6).
2. **Conecta via SSH:** Usa a chave SSH fornecida para se conectar como `ubuntu` na instância indicada.
3. **Cria um backup:** Salva uma cópia da configuração atual do Netplan em `/etc/netplan/50-cloud-init.yaml.old`.
4. **Extrai o MAC address:** Identifica automaticamente o endereço MAC da interface `ens4`, que será usada para configurar a nova rede.
5. **Gera nova configuração:** Reescreve o arquivo Netplan com uma configuração estática de IPv6 para a interface `ens4`, mantendo a `ens3` com DHCP para IPv4.
6. **Aplica a nova configuração:** Executa `netplan apply` para aplicar as alterações de rede.

## ⚠️ Observações importantes

- Os placeholders `<network>`, `<ipv61>` e `<ipv62>` no script devem ser substituídos manualmente com os dados corretos da sua rede (ex: gateway IPv6 e servidores DNS).
- O script usa `StrictHostKeyChecking=no` para evitar prompts interativos na primeira conexão SSH.
- É altamente recomendável revisar a configuração gerada antes de aplicar em ambientes de produção.

## ✅ Resultado Esperado
Ao final da execução, a interface ens4 estará configurada com o IPv6 estático fornecido, e o Netplan aplicado corretamente sem necessidade de intervenção manual.
