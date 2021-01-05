#!/bin/bash

dev_back() {
    cd backend
    poetry run dev_back
}

dev_front() {
    echo "Not yet implemented"
    # cd frontend
    # nvm use 
    # npm run dev
}

for value in $*
do
    if [ $value == "back" ]; then
        echo "Starting backend in dev mode"
        dev_back
    fi
    if [ $value == "front" ]; then
        echo "Starting frontend in dev mode"
        dev_front
    fi
done

