#! /bin/sh

kubectl="kubectl "

if [ ! -d ./config ]; then 
    mkdir -p ./config/secrets
    echo "generating server_key"
    rospo keygen -s -n server_key -p ./config/secrets
    rm ./config/secrets/server_key.pub
    cat <<EOF > ./config/rospo.yaml
sshd:
  server_key: "/etc/rospo/secret/server_key"
  authorized_keys: "https://github.com/ferama.keys"
  listen_address: ":22"
EOF
fi

# secrets
list=""
for file in ./config/secrets/*; do
    if [ -f "$file" ]; then
        list="${list} --from-file=$file"
    fi
done
$kubectl create secret generic rospo-secret \
    $list \
    --dry-run=client -o yaml | $kubectl apply -f -

# configs
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
$kubectl apply -f https://raw.githubusercontent.com/ferama/fermo/main/k8s/crb.yaml
$kubectl apply -f https://raw.githubusercontent.com/ferama/fermo/main/k8s/deployment.yaml
$kubectl rollout restart deployment/rospo
$kubectl apply -f https://raw.githubusercontent.com/ferama/fermo/main/k8s/service.yaml