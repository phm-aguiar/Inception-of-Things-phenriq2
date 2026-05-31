# Guia de Validação — Inception-of-Things

> Este documento contém a sequência de passos para validar cada parte do projeto.

---

## Pré-requisitos

- Vagrant 2.4+ com VirtualBox
- Docker
- k3d
- kubectl (com KUBECONFIG apontando para o k3d ou opção `--context`)
- ~6 GB de RAM livre (3 VMs × 1024 MB + k3d)

---

## P1 — K3s e Vagrant (2 VMs, cluster K3s)

```bash
# 1. Entrar na pasta
cd p1

# 2. Subir as VMs (~3-5 min)
vagrant up

# 3. Verificar status das VMs
vagrant status
# Esperado: phenriq2S running, phenriq2SW running

# 4. Verificar nós do cluster K3s
vagrant ssh phenriq2S -c "export KUBECONFIG=/home/vagrant/.kube/config && kubectl get nodes -o wide"
# Esperado:
#   phenriq2s    Ready   control-plane   192.168.56.110
#   phenriq2sw   Ready   <none>          192.168.56.111

# 5. Verificar IPs
vagrant ssh phenriq2S -c "ip addr show eth1 | grep 192.168.56.110"
vagrant ssh phenriq2SW -c "ip addr show eth1 | grep 192.168.56.111"

# 6. Verificar K3s no server (controller)
vagrant ssh phenriq2S -c "sudo systemctl status k3s --no-pager | head -5"

# 7. Verificar K3s no worker (agent)
vagrant ssh phenriq2SW -c "sudo systemctl status k3s-agent --no-pager | head -5"

# 8. (Opcional) Derrubar as VMs
vagrant halt
# ou destruir: vagrant destroy -f
```

**Critérios de aceite:**
- [ ] phenriq2S: hostname termina em `S`, IP 192.168.56.110, K3s controller, Ready
- [ ] phenriq2SW: hostname termina em `SW`, IP 192.168.56.111, K3s agent, Ready
- [ ] SSH sem senha (gerenciado pelo Vagrant)
- [ ] kubectl funcional no server
- [ ] Recursos: 1 CPU / 1024 MB

---

## P2 — K3s e Três Aplicações (1 VM, 3 apps + Ingress)

```bash
# 1. Entrar na pasta
cd p2

# 2. Subir a VM (~2-3 min)
vagrant up

# 3. Verificar nó
vagrant ssh phenriq2S -c "export KUBECONFIG=/home/vagrant/.kube/config && kubectl get nodes -o wide"
# Esperado: phenriq2s Ready control-plane 192.168.56.110

# 4. Verificar deployments (app2 deve ter 3 réplicas)
vagrant ssh phenriq2S -c "export KUBECONFIG=/home/vagrant/.kube/config && kubectl get deployments"
# Esperado:
#   app1   1/1
#   app2   3/3   ← exatamente 3 réplicas
#   app3   1/1

# 5. Verificar pods
vagrant ssh phenriq2S -c "export KUBECONFIG=/home/vagrant/.kube/config && kubectl get pods"
# Esperado: 5 pods Running (1+3+1)

# 6. Verificar ingress
vagrant ssh phenriq2S -c "export KUBECONFIG=/home/vagrant/.kube/config && kubectl get ingress"
# Esperado: ingress-cool traefik app1.com,app2.com 192.168.56.110

# 7. Testar roteamento por HOST
vagrant ssh phenriq2S -c "
  echo '=== app1.com ==='
  curl -s -H 'Host: app1.com' http://192.168.56.110 | grep -o 'app1-.*</td>'
  echo '=== app2.com ==='
  curl -s -H 'Host: app2.com' http://192.168.56.110 | grep -o 'app2-.*</td>'
  echo '=== default (app3) ==='
  curl -s http://192.168.56.110 | grep -o 'app3-.*</td>'
"
# Esperado: cada requisição retorna um pod do app correspondente

# 8. (Opcional) Derrubar
vagrant halt
```

**Critérios de aceite:**
- [ ] phenriq2S: hostname termina em `S`, IP 192.168.56.110, K3s server
- [ ] app1: HOST app1.com → exibe app1
- [ ] app2: HOST app2.com → exibe app2, **exatamente 3 réplicas**
- [ ] app3: qualquer outro HOST → exibe app3 (default)
- [ ] Recursos: 1 CPU / 1024 MB

---

## P3 — K3d e Argo CD (cluster local + GitOps)

```bash
# 1. Entrar na pasta
cd p3

# 2. Executar setup (~2 min)
bash scripts/setup.sh

# 3. Verificar cluster k3d
k3d cluster list
# Esperado: iotcluster running

# 4. Verificar namespaces
kubectl get namespaces
# Esperado: argocd, dev (e outros do sistema)

# 5. Verificar Argo CD (todos os pods Running)
kubectl get pods -n argocd
# Esperado: ~7 pods com STATUS Running

# 6. Verificar aplicação no namespace dev
kubectl get all -n dev
# Esperado: pod/wil-playground-xxx Running, deployment, replicaset, service

# 7. Verificar imagem da aplicação
kubectl get deployment wil-playground -n dev -o jsonpath='{.spec.template.spec.containers[0].image}'
# Esperado: wil42/playground:v1

# 8. Acessar Argo CD UI (opcional)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
# Acessar: https://localhost:8080
# Login: admin
# Senha: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 9. Testar mudança de versão (v1 → v2)
# Editar p3/manifests/deployment.yaml: image: wil42/playground:v2
# Commit e push para o GitHub
# Verificar no Argo CD UI se o sync automático ocorreu
# Ou via CLI:
kubectl get deployment wil-playground -n dev -o jsonpath='{.spec.template.spec.containers[0].image}'
# Deve mostrar wil42/playground:v2 após o sync

# 10. Rodar script de teste automatizado
bash scripts/test.sh

# 11. (Opcional) Desinstalar
bash scripts/uninstall.sh
```

**Critérios de aceite:**
- [ ] Vagrant NÃO usado
- [ ] K3d + Docker instalados via script setup.sh
- [ ] Namespace `argocd`: Argo CD funcionando
- [ ] Namespace `dev`: aplicação `wil-playground` implantada automaticamente
- [ ] Repositório público no GitHub — ⚠️ nome deve conter login de membro
- [ ] Duas versões tagueadas (v1 e v2)
- [ ] Mudança de v1 → v2 via GitHub dispara sync automático

---

## Notas

- **P1 e P2 usam VirtualBox** — certifique-se de que a virtualização está habilitada na BIOS
- **P3 usa Docker/k3d** — não requer VirtualBox
- As VMs podem coexistir, mas atenção ao consumo de RAM (~3 GB para P1+P2 simultâneos)
- Os scripts de provisionamento instalam o K3s automaticamente; não é necessário instalar manualmente