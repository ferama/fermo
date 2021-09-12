#! /bin/bash

username=fermo
password=fermo

adduser --gecos "" --disabled-password $username
chpasswd <<<"$username:$password"

addgroup fermo sudo