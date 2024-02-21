k3sup install --sudo=false \
 --ip 192.168.4.1 \
 --tls-san=192.168.4.7 \
 --cluster \
 --k3s-extra-args '--flannel-iface=enp2s0 --disable=traefik --disable=servicelb --flannel-backend=none --disable-network-policy --node-ip=192.168.4.1,2a12:zzzz:yyyy:xxxx::1 --cluster-cidr=10.42.0.0/16,fd01::/48 --service-cidr=10.43.0.0/16,fd02::/112' \
 --print-command

cat ~/kubeconfig > .kube/config

sleep 10

kubectl apply -f https://kube-vip.io/manifests/rbac.yaml

ctr image pull docker.io/plndr/kube-vip:0.3.2

ctr run --rm --net-host docker.io/plndr/kube-vip:0.3.2 vip /kube-vip manifest daemonset --arp --interface enp2s0 --address 192.168.4.7 --controlplane --leaderElection --taint --inCluster | tee /var/lib/rancher/k3s/server/manifests/kube-vip.yaml

sleep 20

k3sup join --sudo=false --ip 192.168.4.2 --server --server-ip 192.168.4.7 --k3s-extra-args '--flannel-iface=enp2s0 --disable=traefik --disable=servicelb --flannel-backend=none --disable-network-policy --node-ip=192.168.4.2,2a12:zzzz:yyyy:xxxx::2 --cluster-cidr=10.42.0.0/16,fd01::/48 --service-cidr=10.43.0.0/16,fd02::/112' --print-command

sleep 10

k3sup join --sudo=false --ip 192.168.4.3 --server --server-ip 192.168.4.7 --k3s-extra-args '--flannel-iface=enp2s0 --disable=traefik --disable=servicelb --flannel-backend=none --disable-network-policy --node-ip=192.168.4.3,2a12:zzzz:yyyy:xxxx::3 --cluster-cidr=10.42.0.0/16,fd01::/48 --service-cidr=10.43.0.0/16,fd02::/112' --print-command

sleep 10

cilium install --helm-set ipv6.enabled=true --helm-set ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16" --helm-set ipam.operator.clusterPoolIPv4MaskSize=24 --helm-set ipam.operator.clusterPoolIPv6PodCIDRList="fd01::/48" --helm-set ipam.operator.clusterPoolIPv6MaskSize=64 #--helm-set bgp.enabled=true --helm-set bgp.announce.podCIDR=false --helm-set bgp.announce.loadbalancerIP=true

sleep 15

k3sup join --sudo=false \
    --ip 192.168.4.4 \
    --server-ip 192.168.4.7 \
    --k3s-extra-args '--node-ip=192.168.4.4,2a12:zzzz:yyyy:xxxx::4'\
    --print-command

sleep 15

k3sup join --sudo=false \
    --ip 192.168.4.5 \
    --server-ip 192.168.4.7 \
    --k3s-extra-args '--node-ip=192.168.4.5,2a12:zzzz:yyyy:xxxx::5' \
    --print-command

sleep 15

k3sup join --sudo=false \
    --ip 192.168.4.6 \
    --server-ip 192.168.4.7 \
    --k3s-extra-args '--node-ip=192.168.4.6,2a12:zzzz:yyyy:xxxx::6' \
    --print-command
