source $HOME/.bashrc
gpg-connect-agent /bye
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export NIX_PATH=userpackages=$HOME/user-packages:$NIX_PATH
