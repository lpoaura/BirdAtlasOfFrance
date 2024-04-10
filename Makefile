run_api:
	cd backend && \
	poetry run backend

run_front:
	cd frontend && \
	npm run dev

backend_install:
	cd backend && \
	poetry install

flake8:
	cd backend && \
	poetry run flake8 app

black:
	cd backend && \
	poetry run black app

pylint:
	cd backend && \
	poetry run pylint app
