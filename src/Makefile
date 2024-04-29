.PHONY: format lint all requirements

.DEFAULT_GOAL = help

all: format lint requirements # execute all target

format: # format python file by black formatter and isort
	black .
	isort --atomic .

lint: # lint python file by flake8 and mypy
	flake8 .
	mypy .

requirements: Pipfile # lock and generate requirements from Pipfile
	pipenv lock && pipenv requirements > requirements.txt

install: Pipfile.lock # install dependencies from Pipfile.lock
	pipenv sync --dev

help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done
