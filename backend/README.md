# [API] Bird atlas of France

[![](https://img.shields.io/badge/python-3.7+-yellowgreen)](https://www.python.org)
[![](https://img.shields.io/badge/PostgreSQL-13-blue)](https://www.postgresql.org/) 
[![](https://img.shields.io/badge/code%20style-black-black)](https://github.com/psf/black) 
[![](https://img.shields.io/badge/licence-AGPL--3.0-blue)](https://opensource.org/licenses/AGPL-3.0) 


# HowTo


## Install poetry

Require [poetry](https://python-poetry.org/docs/#installation) project manager installed

```
python3 -m pip install --user poetry
```

## Init env

### Install requirements

```bash
poetry install
```

### Create environment file

in `backend` dir

```bash
cp .env.sample .env
editor .env
```

## Run API

```
poetry run dev_back
```
