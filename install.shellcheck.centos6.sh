#!/bin/bash -x
  # borrowed from https://github.com/koalaman/shellcheck/issues/427
  # Add unofficial Fedora Copr repos
  curl https://copr.fedorainfracloud.org/coprs/petersen/ghc-7.10.3/repo/epel-6/petersen-ghc-7.10.3-epel-6.repo \
      > /etc/yum.repos.d/epel-petersen.repo;

  # Install Haskell
  yum -y install ghc cabal-install cabal-dev >/dev/null 2>&1
  if [ $? -ne 0 ]; then
      echo "this script must be run as root"
      exit 1
  fi

  # Prepare Haskell
  cabal update;
  cabal install cabal-install;

  # Install shellcheck
  cabal install shellcheck;
  if cp -fv ~/.cabal/bin/shellcheck /usr/local/bin/; then
      echo "shellcheck installed to /usr/local/bin"
  else
      echo "shellcheck located at ~/.cabal/bin/shellcheck"
  fi

