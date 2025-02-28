#!/bin/bash

# Stop immediately on any non-zero exit
set -e

echo "Setting up Bash and Git"
cp ./dotfiles/bashrc ~/.bashrc
cp ./dotfiles/bash_profile ~/.bash_profile
cp ./dotfiles/gitconfig ~/.gitconfig
chown "$(whoami):staff" ~/.bashrc ~/.bash_profile ~/.gitconfig

# Xcode install
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools"
#  sudo xcodebuild -runFirstLaunch
  xcode-select --install
  echo -n "GUI prompt should appear to install Xcode CLT - accept it to continue"
  while ! xcode-select -p &>/dev/null; do
    echo -n '.'
    sleep 1
  done
  echo
  echo "Xcode CLT installed."
else
  echo "Xcode Command Line Tools already installed."
fi

# Homebrew install
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing..."
  sudo echo "Enabling a sudo session..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> ~/.zprofile
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew is already installed."
fi

# MacOS defaults config
# Install `macos-defaults`
brew install dsully/tap/macos-defaults
# apply macos-defaults
macos-defaults apply ./macos-defaults/

# Apply Homebrew packages
brew bundle --file=Brewfile

# Apply settings for gpg-agent for yubikey
cp ./dotfiles/gpg-agent.conf ~/.gnupg/gpg-agent.conf
chown "$(whoami):staff"  ~/.gnupg/gpg-agent.conf

# Apply SSH settings and place pubkeys
cp -a ./dotfiles/ssh/ ~/.ssh
chown -R "$(whoami):staff" ~/.ssh
