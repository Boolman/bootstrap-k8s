def label = "mypod-${UUID.randomUUID().toString()}"


// INPUT PARAMETERS
properties([
  parameters([
    string(name: 'OS_AUTH_URL', defaultValue: 'https://auth.example.tld:5000/v3', description: 'Keystone Url', ),
    string(name: 'OS_PROJECT_ID', defaultValue: '1234567789', description: 'Project ID', ),
    string(name: 'OS_PROJECT_NAME', defaultValue: 'MYPROJECT', description: 'Project Name', ),
    string(name: 'OS_USER_DOMAIN_NAME', defaultValue: 'admin_domain', description: 'Domain Name', ),
    string(name: 'OS_USERNAME', defaultValue: 'foo', description: 'Username', ),
    string(name: 'OS_PASSWORD', defaultValue: 'TESTING', description: 'Password', )
   ])
])

// SET ENVIRONMENT VARIABLES
env.OS_AUTH_URL             = params.OS_AUTH_URL
env.OS_PROJECT_ID           = params.OS_PROJECT_ID
env.OS_PROJECT_NAME         = params.OS_PROJECT_NAME
env.OS_USERNAME             = params.OS_USERNAME
env.OS_PASSWORD             = params.OS_PASSWORD
env.OS_USER_DOMAIN_NAME     = params.OS_USER_DOMAIN_NAME
env.OS_REGION_NAME          = 'RegionOne'
env.OS_INTERFACE            = 'public'
env.OS_AUTH_TYPE            = 'password'
env.OS_IDENTITY_API_VERSION = '3'


podTemplate(
  label: label, 
  containers: [
    containerTemplate(name: 'k8s', image: 'lachlanevenson/k8s-kubectl:v1.9.6', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'terraform', image: 'hashicorp/terraform:0.11.6', ttyEnabled: true, command: 'cat', alwaysPullImage: true),
    containerTemplate(name: 'ansible', image: 'boolman/ansible:vanilla', ttyEnabled: true, command: 'cat', alwaysPullImage: true),
    containerTemplate(name: 'openstack-cli', image: 'boolman/openstack-cli:ocata', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'git', image: 'alpine/git', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'consul', image: 'consul:1.0.7', ttyEnabled: true, command: 'consul', args: 'agent -retry-join consul -data-dir /tmp')
    
  ],
  serviceAccount: 'jenkins') {
    node(label) {
      // Fetch terraform
      stage('fetch repo') {
        git branch: 'master', url: 'https://github.com/Boolman/bootstrap-k8s.git'
      }
      stage('git') {
          container('git') {
              stage('update submodules') {
                  sh 'git submodule update --init --recursive'
              }
          }
      }
      stage('openstack-cli') {
          container('openstack-cli') {
              stage('verify openstack settings') {
                  sh """
                      openstack server list
                  """
              }
          }
      }

      stage('terraform') {
          container('terraform') {
              stage('bootstrap openstack env') {
                  sh """
                      terraform version
                      terraform init
                      terraform apply -auto-approve
                  """
              }
          }
      }
      stage('ansible') {
          container('ansible') {
              stage('run k8s playbook') {
                  dir('kubespray') {
                      sleep 60
                      sh """
                          cat ../inventory
                          cp -rp ../group_vars .
                          cp /etc/ansible/ansible.cfg .
                          ansible-playbook -i ../inventory --private-key=../ansible cluster.yml
                          ansible-playbook -i ../inventory --private-key=../ansible ../fetch_k8s_config.yaml
                      """
                  }
              }
          }
      }
      stage('kubectl') {
          container('k8s') {
              stage('deploy jenkins+vault+x on remote k8s') {
                  sh """
                      kubectl --insecure-skip-tls-verify=true --kubeconfig config get nodes
                      kubectl --insecure-skip-tls-verify=true --kubeconfig config -n kube-system create configmap traefik-conf --from-file=k8s/traefik/traefik.toml
                      kubectl --insecure-skip-tls-verify=true --kubeconfig config create -f k8s/traefik/traefik.yaml
                      kubectl --insecure-skip-tls-verify=true --kubeconfig config -n default create -f example/guestbook/guestbook-all-in-one.yaml
                  """
              }
          }
      }
      stage('openstack-cli') {
          container('openstack-cli') {
              stage('update port list') {
                  sh """
                    cat inventory | grep ansible_ssh_host | cut -d "=" -f2 | sort -u | ash update-os-ports.sh
                  """
              }
          }
      }
      stage('store inventory file in consul') {
          container('consul') {
              stage('store inventory in consul') {
                  sh """
                      ash consul_raw
                  """
              }
           }
      }

    }
}
