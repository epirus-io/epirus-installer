#!/bin/sh
epirus_version=${1:-$(curl https://internal.services.web3labs.com/api/epirus/versions/latest)}
installed_flag=0
installed_version=""

check_if_installed() {
  if [ -x "$(command -v epirus)" ] >/dev/null 2>&1; then
    printf 'An Epirus installation exists on your system.\n'
    installed_flag=1
  fi
}

setup_color() {
  # Only use colors if connected to a terminal
  if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
  fi
}

install_epirus() {
  echo "Downloading Epirus ..."
  mkdir -p "$HOME/.epirus"
  if [ "$(curl --write-out "%{http_code}" --silent --output /dev/null "https://github.com/epirus-io/epirus-cli/releases/download/v${epirus_version}/epirus-cli-shadow-${epirus_version}.tar")" -eq 302 ]; then
    curl -# -L -o "$HOME/.epirus/epirus-cli-shadow-${epirus_version}.tar" "https://github.com/epirus-io/epirus-cli/releases/download/v${epirus_version}/epirus-cli-shadow-${epirus_version}.tar"
    echo "Installing Epirus..."
    tar -xf "$HOME/.epirus/epirus-cli-shadow-${epirus_version}.tar" -C "$HOME/.epirus"
    echo "export PATH=\$PATH:$HOME/.epirus" >"$HOME/.epirus/source.sh"
    chmod +x "$HOME/.epirus/source.sh"
    echo "Removing downloaded archive..."
    rm "$HOME/.epirus/epirus-cli-shadow-${epirus_version}.tar"
  else
    echo "Looks like there was an error while trying to download epirus"
    exit 0
  fi
}
get_user_input() {
  while echo "Would you like to update Epirus [Y/n]" && read -r user_input </dev/tty ; do
    case $user_input in
    n)
      echo "Aborting instalation ..."
      exit 0
      ;;
    *)
       echo "Updating Epirus ..."
       break
       ;;
    esac
  done
}

check_version() {
  installed_version=$(epirus version | grep Version | awk -F" " '{print $NF}')
  if [ "$installed_version" = "$epirus_version" ]; then
      echo "You have the latest version of Epirus (${installed_version}). Exiting."
      exit 0
    else
      echo "Your Epirus version is not up to date."
      get_user_input
  fi
}

source_epirus() {
  SOURCE_EPIRUS="\n[ -s \"$HOME/.epirus/source.sh\" ] && source \"$HOME/.epirus/source.sh\""
  if [ -f "$HOME/.bashrc" ]; then
    bash_rc="$HOME/.bashrc"
    touch "${bash_rc}"
    if ! grep -qc '.epirus/source.sh' "${bash_rc}"; then
      echo "Adding source string to ${bash_rc}"
      printf "${SOURCE_EPIRUS}\n" >>"${bash_rc}"
    else
      echo "Skipped update of ${bash_rc} (source string already present)"
    fi
  fi
  if [ -f "$HOME/.bash_profile" ]; then
    bash_profile="${HOME}/.bash_profile"
    touch "${bash_profile}"
    if ! grep -qc '.epirus/source.sh' "${bash_profile}"; then
      echo "Adding source string to ${bash_profile}"
      printf "${SOURCE_EPIRUS}\n" >>"${bash_profile}"
    else
      echo "Skipped update of ${bash_profile} (source string already present)"
    fi
  fi
  if [ -f "$HOME/.bash_login" ]; then
    bash_login="$HOME/.bash_login"
    touch "${bash_login}"
    if ! grep -qc '.epirus/source.sh' "${bash_login}"; then
      echo "Adding source string to ${bash_login}"
      printf "${SOURCE_EPIRUS}\n" >>"${bash_login}"
    else
      echo "Skipped update of ${bash_login} (source string already present)"
    fi
  fi
  if [ -f "$HOME/.profile" ]; then
    profile="$HOME/.profile"
    touch "${profile}"
    if ! grep -qc '.epirus/source.sh' "${profile}"; then
      echo "Adding source string to ${profile}"
      printf "$SOURCE_EPIRUS\n" >>"${profile}"
    else
      echo "Skipped update of ${profile} (source string already present)"
    fi
  fi

  if [ -f "$(command -v zsh 2>/dev/null)" ]; then
    file="$HOME/.zshrc"
    touch "${file}"
    if ! grep -qc '.epirus/source.sh' "${file}"; then
      echo "Adding source string to ${file}"
      printf "$SOURCE_EPIRUS\n" >>"${file}"
    else
      echo "Skipped update of ${file} (source string already present)"
    fi
  fi
}

check_if_epirus_homebrew() {
  if (command -v brew && ! (brew info epirus 2>&1 | grep -e "Not installed\|No available formula") >/dev/null 2>&1); then
    echo "Looks like Epirus is installed with Homebrew. Please use Homebrew to update. Exiting."
    exit 0
  fi
}

clean_up() {
  if [ -d "$HOME/.epirus" ]; then
    rm -f "$HOME/.epirus/source.sh"
    rm -rf "$HOME/.epirus/epirus-$installed_version" >/dev/null 2>&1
    echo "Deleting older installation ..."
  fi
}

completed() {
  ln -sf "$HOME/.epirus/epirus-$epirus_version/bin/epirus" $HOME/.epirus/epirus
  printf '\n'
  printf "$GREEN" 
  echo "Epirus was succesfully installed."
  echo "To use epirus in your current shell run:"
  echo "source \$HOME/.epirus/source.sh"
  echo "When you open a new shell this will be performed automatically."
  echo "To see what epirus's CLI can do you can check the documentation bellow."
  echo "https://docs.epirus.io/command_line_tools/ "
  printf "$RESET" 
  exit 0
}

main() {
  setup_color
  check_if_installed
  if [ $installed_flag -eq 1 ]; then
    check_if_epirus_homebrew
    check_version
    clean_up
    install_epirus
    source_epirus
    completed
  else
    install_epirus
    source_epirus
    completed    
  fi
}

main
