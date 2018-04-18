set -e
netone=$(cat group_vars/k8s-cluster.yaml | grep ^kube_service_addresses | awk '{print $2}')
nettwo=$(cat group_vars/k8s-cluster.yaml | grep ^kube_pods_subnet | awk '{print $2}')

while IFS= read -r host
do
  ip=$(openstack server list -f value -c Networks | grep ${host} | grep -E -o "\w+=[^ ,]+" | cut -d "=" -f2)
  openstack port list -c ID -c 'Fixed IP Addresses' -f value | grep ${ip} | awk '{print $1}' | xargs -r -IPORTID echo openstack port set --allowed-address ip-address=${netone} --allowed-address ip-address=${nettwo} PORTID
done
