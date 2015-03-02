#!/bin/bash
set -e
set -x

sudo pip install virtualenv

mkdir -p ~/Virtualenvs
cd ~/Virtualenvs
virtualenv lf
