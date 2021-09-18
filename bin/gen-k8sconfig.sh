#! /bin/bash

setup-kubectl.sh

tmpdir=$(mktemp -d)
cat ~/.kube/config > $tmpdir/config
cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt > $tmpdir/ca.crt

# extract the api url
api_url=$(kubectl cluster-info | head -n 1 | sed -n 's/^.*\(https:\/\/.*\)$/\1/p')
# removes garbage
api_url=${api_url%????}

sed -i.bak -e "s|server: \(.*\)$|server: ${api_url}|g" $tmpdir/config

# put certs as base64 into config
conf=$(
    python3 << END
import re, base64
with open("$tmpdir/ca.crt", "r") as file:
    cert = file.read()
    cert = base64.b64encode(cert.encode('ascii')).decode('ascii')
with open("$tmpdir/config", "r") as file:
    conf = file.read()
    conf = re.sub(r'certificate-authority: (.*)', f'certificate-authority-data: {cert}', conf)
    print(conf)
END
)
echo "$conf" > $tmpdir/config

cp $tmpdir/config ./config-${RANDOM}