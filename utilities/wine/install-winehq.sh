#!/usr/bin/env bash
YW=`echo "\033[33m"`
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
RETRY_NUM=10
RETRY_EVERY=3
NUM=$RETRY_NUM
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR="\\r\\033[K"
HOLD="-"
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR

function error_exit() {
  trap - ERR
  local reason="Unknown failure occurred."
  local msg="${1:-$reason}"
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  exit $EXIT
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}
function msg_error() {
    local msg="$1"
    echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

echo " __          ___            _    _  ____   "
echo " \ \        / (_)   V1.0   | |  | |/ __ \  "
echo "  \ \  /\  / / _ _ __   ___| |__| | |  | | "
echo "   \ \/  \/ / | | '_ \ / _ \  __  | |  | | "
echo "    \  /\  /  | | | | |  __/ |  | | |__| | "
echo "     \/  \/   |_|_| |_|\___|_|  |_|\___\_\ "
echo "-------------------------------------------"
echo ""
echo "You are about to install WineHQ: Stable"

while true; do

read -p "Do you want to proceed? (y/n) " yn

case $yn in 
	[yY] )
		break;;
	[nN] ) echo Exiting...;
		exit;;
	* ) echo Invalid response;;
esac

done
echo ""
PS3='Select your Ubuntu version: '
options=("Ubuntu 22.04 (Jammy)" "Ubuntu 20.04 (Focal)" "Ubuntu 18.04 (Bionic)")
select opt in "${options[@]}"
do
    case $opt in
        "Ubuntu 22.04 (Jammy)")
            WHQ_SOURCE="https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources"
            break
            ;;
        "Ubuntu 20.04 (Focal)")
            WHQ_SOURCE="https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources"
            break
            ;;
        "Ubuntu 18.04 (Bionic)")
            WHQ_SOURCE="https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/winehq-bionic.sources"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

msg_info "Enabling 32 bit architecture"
dpkg --add-architecture i386 
msg_ok "Enabled 32 bit architecture"

msg_info "Adding WineHQ repository"
mkdir -pm755 /etc/apt/keyrings 
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key &>/dev/null
wget -NP /etc/apt/sources.list.d/ $WHQ_SOURCE &>/dev/null
msg_ok "Added WineHQ repository"
sleep 1
msg_info "Updating package lists"
apt update &>/dev/null
msg_ok "Updated package lists"

msg_info "Installing WineHQ: Stable"
apt install -y --install-recommends winehq-stable &>/dev/null
msg_ok "Installed WineHQ: Stable"
  
msg_info "Cleaning up"
apt-get autoremove >/dev/null
apt-get autoclean >/dev/null
msg_ok "Cleaned"