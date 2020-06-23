#!/bin/bash
set -e
if [ -f "C:\\windows\\system32\\drivers\\etc\\hosts" ]; then
  choco install -y jdk8
  export JAVA_HOME="C:\\Program Files\\Java\\jdk1.8.0_211"
  powershell -executionpolicy bypass .\\installer.ps1
  chmod +x ~/.epirus/*/bin/epirus.bat

  ~/.epirus/*/bin/epirus.bat version
  exit 0
fi

sh installer.sh
echo "Epirus source script content:"
cat $HOME/.epirus/source.sh
echo "Sourcing epirus source script"
source $HOME/.epirus/source.sh
echo "Content of bashrc:"
cat ~/.bashrc
echo "System path:"
echo $PATH
epirus --version
