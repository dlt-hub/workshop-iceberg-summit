dev:
	uv sync --reinstall-package dlt --upgrade-package dlt --reinstall-package dlt-plus --upgrade-package dlt-plus --all-extras --group dev --no-managed-python

lint:
	uv run mypy . --no-namespace-packages --exclude _data
	uv run ruff check .
	uv run ruff format --check .

lint-fix:
	uv run ruff check --fix .

format:
	uv run ruff format .

format-fix: format lint-fix

build: dev
	rm -rf dist
	uv build --all -o dist

docker: build
	docker build . -t dlt_portable_data_lake_demo

build-and-publish-release: build
	# upload artifacts to private pypi
	# this setup will NOT OVERWRITE existing files on the private pypi
	# NOTE: the env var UV_PUBLISH_PASSWORD will need to be set
	uv publish --publish-url https://pypi.dlthub.com --username upload --password ${UV_PUBLISH_PASSWORD} ./dist/dlt_portable_data_lake*

test:
	uv run pytest

audit:
	dlt project --profile prod audit
	dlt project --profile access audit

run: download-gh
	dlt project clean
	dlt pipeline -l
	dlt pipeline events_to_lake run
	dlt dataset github_events_dataset row-counts
	dlt transformation . run
	dlt dataset reports_dataset info
	dlt dataset reports_dataset row-counts

run-cont:
	
	dlt dataset github_events_dataset row-counts
	dlt transformation . run
	dlt dataset reports_dataset info
	dlt dataset reports_dataset row-counts

download-gh:
	mkdir -p dlt_portable_data_lake_demo/_data
	cd dlt_portable_data_lake_demo/_data && wget https://data.gharchive.org/2024-10-13-15.json.gz

.PHONY: tests