SHELL := /usr/bin/env bash

args = `arg="$(filter-out $(firstword $(MAKECMDGOALS)),$(MAKECMDGOALS))" && echo $${arg:-${1}}`

green  = $(shell printf "\e[32;01m$1\e[0m")
yellow = $(shell printf "\e[33;01m$1\e[0m")
red    = $(shell printf "\e[33;31m$1\e[0m")

format = $(shell printf "%-40s %s" "$(call green,bin/$1)" $2)

comma:= ,

.DEFAULT_GOAL:=help

%:
	@:

help:
	@echo ""
	@echo "$(call yellow,Use the following CLI commands:)"
	@echo "$(call red,===============================)"
	@echo "$(call format,root,'Run any CLI command as root without going into the bash prompt.')"
	@echo "$(call format,bash,'Drop into the bash prompt of your Docker container.')"
	@echo "$(call format,cli,'Run any CLI command without going into the bash prompt.')"
	@echo "$(call format,docker-compose,'Support V1 (`docker-compose`) and V2 (`docker compose`) docker compose command, and use custom configuration files.')"
	@echo "$(call format,docker-stats,'Display status for CPU$(comma) memory usage$(comma) and memory limit of currently-running Docker containers.')"
	@echo "$(call format,log,'Monitor the log files. Pass no params to tail all files.')"
	@echo "$(call format,restart,'Stop and then start all containers.')"
	@echo "$(call format,setup,'Setup the project for the first time.')"
	@echo "$(call format,start,'Start all containers.')"
	@echo "$(call format,status,'Check the container status.')"
	@echo "$(call format,stop,'Stop all project containers.')"
	@echo "$(call format,update,'Update your project to the latest version.')"

bash:
	@./usr/bin/env bash

cli:
	@./bin/cli $(call args)

docker-compose:
	@./bin/docker-compose

docker-stats:
	@./bin/docker-stats

log:
	@./bin/log $(call args)

restart:
	@./bin/restart $(call args)

root:
	@./bin/root $(call args)

setup:
	@./bin/setup

start:
	@./bin/start $(call args)

status:
	@./bin/status

stop:
	@./bin/stop $(call args)

update:
	@./bin/update
