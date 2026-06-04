#!/bin/bash
set -e

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --bind-address=192.168.56.110 \
  --advertise-address=192.168.56.110 \
  --node-ip=192.168.56.110" sh -

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# waiting for k3s to be ready
sleep 10
kubectl wait --for=condition=Ready node --all --timeout=120s

# deploy app1 pod and service
kubectl apply -f /vagrant/app1.yaml

# deploy app2 pod and service
kubectl apply -f /vagrant/app2.yaml

# deploy app3 pod and service
kubectl apply -f /vagrant/app3.yaml

# apply ingress
kubectl apply -f /vagrant/ingress.yaml

until kubectl get ingress ingress-cool | grep -q "192.168.56.110"; do
  echo "waiting ingress Ip..."
  sleep 50
done
echo "ingress ready"
