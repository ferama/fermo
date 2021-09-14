#! /bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

do_install() {
    # create secrets
    list=""
    for file in ./config/secrets/*; do
        if [ -f "$file" ]; then
            list="${list} --from-file=$file"
        fi
    done
    $kubectl create secret generic rospo-secret \
        $list \
        --dry-run=client -o yaml | $kubectl apply -f -
    
    # create configs
    list=""
    for file in ./config/*; do
        if [ -f "$file" ]; then
            list="${list} --from-file=$file"
        fi
    done
    $kubectl create configmap rospo-config \
        $list \
        --dry-run=client -o yaml | $kubectl apply -f -

    # other k8s resources
    $kubectl apply -f ./k8s/crb.yaml

    # $kubectl apply -f ./k8s/volumes.yaml
    # $kubectl apply -f ./k8s/deployment-persistent.yaml

    $kubectl apply -f ./k8s/deployment.yaml

    $kubectl apply -f ./k8s/service.yaml
    $kubectl rollout restart deployment/rospo
}

make_default_config() {
    if [ ! -d ./config ]; then 
        mkdir -p ./config/secrets
        echo "generating server_key"
        rospo keygen -s -n server_key -p ./config/secrets
        rm ./config/secrets/server_key.pub
        cat <<EOF > ./config/rospo.yaml
sshd:
    server_key: "/etc/rospo/secret/server_key"
    authorized_keys: 
        - "https://github.com/<put_your_github_user_here>.keys"
    listen_address: ":2222"
EOF
        echo "please review the config starter in ./config dir"
        exit 0
    fi
}


usage() { 
    echo "Usage: $0 [-k <string>] [-i | -u]
    
    -k to set an alternate kubectl config file
    -i to install 
    -u to uninstall 
    " 1>&2; exit 1; 
}
[ $# -eq 0 ] && usage

kubeconfig=""
u_flag=false
i_flag=false
while getopts "hk:iu" arg; do
  case $arg in
    k)
        echo "Using Kubeconfig at: ${OPTARG}"
        kubeconfig=${OPTARG}
        ;;
    u) 
        u_flag=true
        ;;
    i) 
        i_flag=true
        ;;
    h | *)
      usage
      exit 0
      ;;
  esac
done

if ! $u_flag && ! $i_flag; then usage; fi
if $u_flag && $i_flag; then usage; fi

kubectl="kubectl"
if [ ! -z $kubeconfig ]
then
    kubectl="kubectl --kubeconfig=$kubeconfig"
fi

if $i_flag; then
    echo "Running install"
    make_default_config
    do_install
fi
if $u_flag; then
    echo "TODO: uninstall"
fi
