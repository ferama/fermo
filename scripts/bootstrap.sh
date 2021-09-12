#! /bin/bash

username=fermo
password=fermo

groupadd docker
adduser --gecos "" --disabled-password $username
chpasswd <<<"$username:$password"

addgroup $username sudo
addgroup $username docker
