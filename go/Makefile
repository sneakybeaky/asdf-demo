.setup_ok: .tool-versions .envrc
	@script/setup.sh && touch .setup_ok
	
setup: .setup_ok
	@echo "System is setup"

install:
	@script/install-tools.sh
