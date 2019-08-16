set -eu
set -x

curl https://nim-lang.org/choosenim/init.sh -sSf > init.sh
sh init.sh -y
nim c || true
echo "export PATH=~/.nimble/bin:$PATH" >> ~/.profile
choosenim $CHANNEL