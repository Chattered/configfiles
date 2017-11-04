source $HOME/.bashrc
export GNUPGHOME=/tails/gnupg
gpg-connect-agent /bye
gpgconf --create-socketdir
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export NIX_PATH=userpackages=$HOME/user-packages:$NIX_PATH
export DIOS=/dev/disk/by-id/wwn-0x5000c5004f969599-part1
export MP3=/dev/disk/by-id/usb-ACTIONS_HS_USB_FlashDisk_4512482ADF0FEEEE
export EDITOR=emacs
