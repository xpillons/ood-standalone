#!/bin/bash
set -e
# Installs Ansible. Optionally in a conda environment.
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MINICONDA_URL_LINUX_X86="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
MINICONDA_INSTALL_DIR=${1:-miniconda}
MINICONDA_INSTALL_SCRIPT="miniconda-installer.sh"

os_type=$(uname | awk '{print tolower($0)}')
os_arch=$(arch)
miniconda_url=$MINICONDA_URL_LINUX_X86

# Reuse environment if it doesn't already exist
if [[ ! -d "${MINICONDA_INSTALL_DIR}" ]]; then
    printf "Installing Ansible in conda environment in %s from %s \n\n" "${MINICONDA_INSTALL_DIR}" "${miniconda_url}"

    # Actually install environment and install in base environment
    if [[ ! -f ${MINICONDA_INSTALL_SCRIPT} ]]; then
        wget $miniconda_url -O $MINICONDA_INSTALL_SCRIPT
    fi
    bash $MINICONDA_INSTALL_SCRIPT -b -p $MINICONDA_INSTALL_DIR
    source "${MINICONDA_INSTALL_DIR}/bin/activate"
else
    printf "Installing Ansible in existing conda environment in %s \n\n" "${MINICONDA_INSTALL_DIR}"
    source "${MINICONDA_INSTALL_DIR}/bin/activate"
fi

printf "Update packages"
conda update -y --all

# Install Ansible
printf "Installing Ansible\n"
python3 -m pip install -r ${THIS_DIR}/requirements.txt

printf "\n\n"
printf "Applications installed\n"
printf "===============================================================================\n"
columns="%-16s| %.10s\n"
printf "$columns" Application Version
printf -- "-------------------------------------------------------------------------------\n"
printf "$columns" Python `python3 --version | awk '{ print $2 }'`
printf "$columns" Ansible `ansible --version | head -n 1 | awk '{ print $3 }' | sed 's/]//'`
printf "===============================================================================\n"

if [ $INSTALL_IN_CONDA = true ]; then
    yellow=$'\e[1;33m'
    default=$'\e[0m'
    printf "\n${yellow}Dependencies installed in a conda environment${default}. To activate, run:\n"
    printf "\nsource %s/bin/activate\n\n" "${MINICONDA_INSTALL_DIR}"
fi
