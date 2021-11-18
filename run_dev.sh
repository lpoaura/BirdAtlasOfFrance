#!/bin/bash

# install_back() {
#     echo "****************************************"
#     echo "*         Installation du backend       "
#     echo "****************************************"
#     echo ""
#     echo "Téléchargement et installation de PYENV"
#     #curl https://pyenv.run | bash
#     #git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
#     #exec $SHELL
#     echo "Create project virtualenv (odf)"
#     cd backend
#     pyenv install 3.7.9
#     pyenv virtualenv 3.7.9 odf
#     pyenv activate odf
#     echo ""
#     echo "Téléchargement et installation de POETRY"
#     echo ""
#     curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -
#     echo "Installation des dépendances du backend"
#     cd backend
#     poetry install

# }

# install_front() {
#     echo "Téléchargement et installation de NVM"
#     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
#     echo "Installation des dépendances du frontend"
#     cd frontend
#     nvm install
# }

dev_back() {
    cd backend
    poetry run dev_back
}

dev_front() {
    cd frontend
    nvm use
    npm run dev
}

for value in $*; do
    # if [ $value == "install_back" ]; then
    #     echo "Starting backend install"
    #     install_back
    # fi
    #     if [ $value == "install_front" ]; then
    #     echo "Starting frontend install"
    #     install_front
    # fi
    if [ $value == "run_back" ]; then
        echo "Starting backend in dev mode"
        dev_back
    fi
    if [ $value == "run_front" ]; then
        echo "Starting frontend in dev mode"
        dev_front
    fi
    if [ $value == "run_all" ]; then
        echo "Starting frontend in dev mode"
        dev_back &
        dev_front
    fi
done
