# Makefile for Rust and Move Sui

# SUI CLI Command 
MOVE=sui move
CLIENT=sui client

BUILD=$(MOVE) build --lint
TEST=$(MOVE) test --lint
#COV=$(MOVE) coverage summary

FAUCET=$(CLIENT) faucet
GAS=$(CLIENT) gas

PUBLISH=$(SUI) publish
UPGRADE=$(SUI) upgrade
VERIFY=$(SUI) verify

# Emoji Variables, why not?
EMOJI_BUILD=📦
EMOJI_TEST=🧪
EMOJI_CLEAN=🧹
#EMOJI_COV=✅
EMOJI_FAUCET=🫰
EMOJI_GAS=⛽
EMOJI_PUBLISH=🚀
EMOJI_UPGRADE=🗿
EMOJI_VERIFY=🔍
EMOJI_CONSOLE=🖥️
EMOJI_HELP=❓

.PHONY: all lint build test coverage clean

# All the nitty gritty sui useful commands for the challenge
# https://docs.sui.io/doc/sui-cli-cheatsheet.pdf

## Global commands

# Buidl
build:
	@echo "$(EMOJI_BUILD) Building package..."
	$(BUILD) 


# Global Test
test:
	@echo "$(EMOJI_TEST) Running aynrand tests..."
	$(TEST) 

# Clean, to remove artifacts
clean:
	@echo "$(EMOJI_CLEAN) Cleaning up the thing..."
	rm -rf build
	rm -rf *lock*
	rm -rf target



#coverage:
##	@echo "$(EMOJI_COV) Generating test coverage reports..."
##	$(TEST)
##	$(COV) || echo "No coverage data available"

## Operational Commands
faucet:
	@echo "$(EMOJI_FAUCET) Gimme the fake money..."
	# $(FAUCET)
	@echo "$(EMOJI_GAS) Show me the gass..."
	$(GAS)
	
publish:
	@echo "$(EMOJI_PUBLISH) Publishing the Aynrand smart contract..."
	$(PUBLISH)

upgrade:
	@echo "$(EMOJI_UPGRADE) Upgrading the codebase..."
	$(UPGRADE)

verify:
	@echo "$(EMOJI_VERIFY) Verifying Aynrand!..."
	$(VERIFY)
	
console:
	@echo "$(EMOJI_CONSOLE) Interactive CLI..."
	$(VERIFY)



help:
	@echo "Aynrand tooling"
	@echo "Available commands:"
	@echo "  all       - build, test, clean, lint, coverage, faucet, verify, publish"
	@echo "  build     - $(EMOJI_BUILD) Compile the Move package"
	@echo "  test      - $(EMOJI_TEST) Run project tests"
	@echo "  clean     - $(EMOJI_CLEAN) Remove build artifacts"
	@echo "  lint      - $(EMOJI_LINT) Analyze and lint code"
	@echo "  coverage  - $(EMOJI_COV) Generate test coverage report"
	@echo "  faucet    - $(EMOJI_FAUCET) Request testnet tokens"
	@echo "  publish   - $(EMOJI_PUBLISH) Publish Move package"
	@echo "  upgrade   - $(EMOJI_UPGRADE) Upgrade Move package"
	@echo "  verify    - $(EMOJI_VERIFY) Verify package integrity"
	@echo "  console   - $(EMOJI_CONSOLE) Start Sui interactive console"
	@echo "  help      - $(EMOJI_HELP) Show this help message"


