PKG = api

.PHONY: clean init

service_up:
	docker-compose up -d postgres

service_down:
	docker-compose down && docker volume rm postgres_data

init: clean
	pipenv --python 3.8
	pipenv install --dev

lint:
	pipenv run flake8 ${PKG} --max-line-length=120
	pipenv run pylint --rcfile=setup.cfg ${PKG}/**

analysis:
	pipenv run bandit ${PKG}

format:
	pipenv run black ${PKG}
	pipenv run isort ${PKG}

ci-bundle: analysis format lint test

test:
	pipenv run pytest -vv --cov-report=term-missing --cov=api/endpoints api/tests

clean:
	find . -type f -name '*.py[co]' -delete
	find . -type d -name '__pycache__' -delete
	rm -rf dist
	rm -rf build
	rm -rf *.egg-info
	rm -rf .hypothesis
	rm -rf .pytest_cache
	rm -rf .tox
	rm -f report.xml
	rm -f coverage.xml
