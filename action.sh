#!/bin/bash

set -eu

readonly SEALOS_CMD=${cmd:-install}

###
readonly INSTALL_SEALOS_VERSION=${sealos_version:-4.1.4}
readonly INSTALL_SEALOS_GIT=${sealosGit:-https://github.com/labring/sealos.git}


{
  echo "download buildah in https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
  wget -qO "buildah" "https://github.com/labring/cluster-image/releases/download/depend/buildah.linux.amd64"
  chmod a+x buildah
  sudo mv buildah /usr/bin
}
{
  sudo apt-get remove docker docker-engine docker.io containerd runc
  sudo apt-get purge docker-ce docker-ce-cli containerd.io # docker-compose-plugin
  sudo apt-get remove -y moby-engine moby-cli moby-buildx moby-compose
}
{
  case $SEALOS_CMD in
  	install)
  	  echo "download sealos sealctl in https://github.com/labring/sealos/releases/download/v${INSTALL_SEALOS_VERSION}/sealos_${INSTALL_SEALOS_VERSION}_linux_amd64.tar.gz"
  	  sudo wget -q https://github.com/labring/sealos/releases/download/v${INSTALL_SEALOS_VERSION}/sealos_${INSTALL_SEALOS_VERSION}_linux_amd64.tar.gz
  	  sudo tar -zxvf sealos_${INSTALL_SEALOS_VERSION}_linux_amd64.tar.gz sealos &&  chmod +x sealos && mv sealos /usr/bin
  	  sudo tar -zxvf sealos_${INSTALL_SEALOS_VERSION}_linux_amd64.tar.gz sealctl &&  chmod +x sealctl && mv sealctl /usr/bin
  	  ;;
  	install-dev)
      git clone $INSTALL_SEALOS_GIT
      sudo apt update && sudo apt install -y libgpgme-dev libbtrfs-dev libdevmapper-dev
      cd sealos
      go install golang.org/dl/go1.20@latest
      whereis go1.20
      go1.20 download
      BINS=sealos make build
      BINS=sealctl make build
      sudo chmod a+x bin/linux_amd64/* && sudo mv bin/linux_amd64/* /usr/bin
      ;;
    *)
      echo "unknown cmd"
      exit 1
      ;;
  esac
}
