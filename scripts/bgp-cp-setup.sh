cilium config set enable-bgp-control-plane true
sleep 20
pod=$(kubectl get pods -n kube-system -o name | grep cilium-operator)
kubectl delete -n kube-system $pod
sleep 60
kubectl apply -f cilium-lb/lbippool.yaml
kubectl apply -f cilium-lb/bgp.yaml
sleep 10
kubectl label nodes node01 node02 node03 node04 node05 node06 bgp-policy=default
