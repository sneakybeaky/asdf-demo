ENV_FILE := $(or ${ENV_FILE},.env.override)

ifneq ("$(wildcard $(ENV_FILE))","")
	include $(ENV_FILE)
	export $(shell sed 's/=.*//' $(ENV_FILE))
endif

setup:
	chmod +x ./scripts/$@.sh
	./scripts/$@.sh

teardown:
	chmod +x ./scripts/$@.sh
	./scripts/$@.sh
