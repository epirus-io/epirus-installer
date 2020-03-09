# epirus-installer
Command line installer for Epirus

### How to (Linux/macOS):
In a terminal, run the following command:

`curl -L get.epirus.io | sh`

This script will not work if Epirus has been installed using Homebrew on macOS.

### How to (Windows):
In PowerShell, run the following command:

`Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/epirus-io/epirus-installer/master/installer.ps1'))`