export POETRY_HTTP_BASIC_MONDU_USERNAME := aws
export POETRY_HTTP_BASIC_MONDU_PASSWORD := $(shell aws codeartifact get-authorization-token --domain artifact-prod-mondu-ai --domain-owner 597114965490 --region eu-central-1 --query authorizationToken --output text --profile prod)

.PHONY: all tests clean

install-dev:
	poetry install

format:
	poetry run isort .
	poetry run black .

check:
	poetry run isort . -c
	poetry run black . --check
	poetry run bandit -r feature_store -c "pyproject.toml"
	poetry run flake8 feature_store
	poetry run pylint feature_store

tests:
	poetry run python -m pytest -v tests -m "not (slow or stage or features)" --cov=./feature_store

slow-tests:
	poetry run python -m pytest -v tests -m "slow" --cov=./feature_store

features-tests:
	poetry run python -m pytest -v tests -m "features" --cov=./feature_store

run-docker:
	docker-compose down -v
	docker-compose up --force-recreate

produce:
	poetry run python produce.py

consume:
	poetry run python consume.py

serving:
	poetry run python serving.py
