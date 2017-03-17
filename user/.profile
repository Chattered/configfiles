source $HOME/.bashrc
export GNUPGHOME=/tails/gnupg
gpg-connect-agent /bye
gpgconf --create-socketdir
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export NIX_PATH=userpackages=$HOME/user-packages:$NIX_PATH
export GIT_SSH_COMMAND="ssh -i /tails/openssh-client/id_rsa"
