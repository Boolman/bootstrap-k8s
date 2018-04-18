resource "null_resource" "ansible-provision" {
  depends_on = ["openstack_compute_instance_v2.k8s"]
  
  ## Create hostgroup
  provisioner "local-exec" {
    command =  "echo \"\n[kube-master]\" > inventory"
  }
  ## Populate
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s.*.name, openstack_compute_floatingip_v2.node-ip.*.address))}\" >> inventory"
  }
  
  ## Create hostgroup
  provisioner "local-exec" {
    command =  "echo \"\n[kube-node]\" >> inventory"
  }
  ## Populate
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s.*.name, openstack_compute_floatingip_v2.node-ip.*.address))}\" >> inventory"
  }

  ## Create hostgroup
  provisioner "local-exec" {
    command =  "echo \"\n[etcd]\" >> inventory"
  }
  ## Populate
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s.*.name, openstack_compute_floatingip_v2.node-ip.*.address))}\" >> inventory"
  }

  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:children]\nkube-master\nkube-node\" >> inventory"
  }

  ## Generate consul commands
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("consul kv put inventory/kube-master/%s:ansible_ssh_host=%s", openstack_compute_instance_v2.k8s.*.name, openstack_compute_floatingip_v2.node-ip.*.address))}\" >> consul_raw"
  }

  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("consul kv put inventory/kube-node/%s:ansible_ssh_host=%s", openstack_compute_instance_v2.k8s.*.name, openstack_compute_floatingip_v2.node-ip.*.address))}\" >> consul_raw"
  }

  provisioner "local-exec" {
    command =  "echo \"\nconsul kv put inventory/k8s-cluster:children/kube-master\" >> consul_raw"
  }
  provisioner "local-exec" {
    command =  "echo \"\nconsul kv put inventory/k8s-cluster:children/kube-node\" >> consul_raw"
  }
}
