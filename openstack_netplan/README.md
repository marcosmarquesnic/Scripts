> Este README.md gerado pelo chatGPT 

# Configurador de IPv6 via SSH

Este script conecta-se a uma instância via SSH, realiza backup da configuração atual do Netplan, configura um IPv6 fixo na interface `ens4` e aplica a nova configuração.

## Pré-requisitos

- Acesso SSH à instância via chave pública previamente autorizada.
- O script deve ser executado como um usuário com acesso SSH funcional.
- A interface de rede da instância deve ser `ens4` (ou ajuste conforme necessário).
- Preencher os placeholders `<network>`, `<ipv61>`, `<ipv62>` no script com valores reais de gateway e DNS IPv6.

## Uso

```bash
./configurar_ipv6.sh <IPv4> <USUARIO> <IPv6>
```

### Exemplo:

```bash
./configurar_ipv6.sh 192.168.0.10 ubuntu 2804:abcd:1234::1
```

## O que o script faz:

1. Conecta-se via SSH à instância.
2. Faz backup da configuração Netplan com timestamp.
3. Extrai o MAC address da interface `ens4`.
4. Substitui a configuração atual com o novo IPv6.
5. Aplica o Netplan.

## Observações

- Se for executar como `root`, certifique-se de que a chave SSH esteja presente no diretório `~/.ssh/` do root.
- A configuração substitui completamente o conteúdo do arquivo `/etc/netplan/50-cloud-init.yaml porém salva uma cópia no mesmo diretorio`.
