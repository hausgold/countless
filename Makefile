MAKEFLAGS += --warn-undefined-variables -j1
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.PHONY:

# Environment switches
MAKE_ENV ?= docker
COMPOSE_RUN_SHELL_FLAGS ?= --rm
BASH_RUN_SHELL_FLAGS ?=
CLOC_VERSION ?= v1.94
CLOC_BASE_URL ?= https://github.com/AlDanial/cloc
CLOC_URL ?= $(CLOC_BASE_URL)/releases/download/$(CLOC_VERSION)/cloc-1.94.pl

# Directories
VENDOR_DIR ?= vendor/bundle
GEMFILES_DIR ?= gemfiles
BIN_DIR ?= bin

# Host binaries
BASH ?= bash
CHMOD ?= chmod
COMPOSE ?= docker-compose
CURL ?= curl
ID ?= id
MKDIR ?= mkdir
RM ?= rm

# Container binaries
APPRAISAL ?= appraisal
BUNDLE ?= bundle
GUARD ?= guard
RAKE ?= rake
RSPEC ?= rspec
RUBOCOP ?= rubocop
YARD ?= yard

# Files
GEMFILES ?= $(subst _,-,$(patsubst $(GEMFILES_DIR)/%.gemfile,%,\
	$(wildcard $(GEMFILES_DIR)/*.gemfile)))
TEST_GEMFILES := $(GEMFILES:%=test-%)

# Define a generic shell run wrapper
# $1 - The command to run
ifeq ($(MAKE_ENV),docker)
define run-shell
	$(COMPOSE) run $(COMPOSE_RUN_SHELL_FLAGS) \
		-e LANG=en_US.UTF-8 -e LANGUAGE=en_US.UTF-8 -e LC_ALL=en_US.UTF-8 \
		-e HOME=/tmp -e BUNDLE_APP_CONFIG=/app/.bundle \
		-u `$(ID) -u` test \
		bash $(BASH_RUN_SHELL_FLAGS)  -c 'sleep 0.1; echo; $(1)'
endef
else ifeq ($(MAKE_ENV),baremetal)
define run-shell
	$(1)
endef
endif

all:
	# Countless
	#
	# install            Install the dependencies
	# update             Update the local Gemset dependencies
	# clean              Clean the dependencies
	#
	# test               Run the whole test suite
	# test-style         Test the code styles
	# watch              Watch for code changes and rerun the test suite
	#
	# docs               Generate the Ruby documentation of the library
	# stats              Print the code statistics (library and test suite)
	# notes              Print all the notes from the code
	# release            Release a new Gem version (maintainers only)
	#
	# shell              Run an interactive shell on the container
	# shell-irb          Run an interactive IRB shell on the container

.interactive:
	@$(eval BASH_RUN_SHELL_FLAGS = --login)

install:
	# Install the dependencies
	@$(MKDIR) -p $(VENDOR_DIR)
	@$(call run-shell,$(BUNDLE) check || $(BUNDLE) install --path $(VENDOR_DIR))
	@$(call run-shell,$(BUNDLE) exec $(APPRAISAL) install)
	@$(MAKE) --no-print-directory .fetch-cloc

update:
	# Install the dependencies
	@$(MKDIR) -p $(VENDOR_DIR)
	@$(call run-shell,$(BUNDLE) update)
	@$(call run-shell,$(BUNDLE) exec $(APPRAISAL) update)

.fetch-cloc:
	# Fetch the CLOC ($(CLOC_VERSION)) binary
ifeq ("$(wildcard $(BIN_DIR)/cloc)","")
	@$(CURL) -L '$(CLOC_URL)' -o '$(BIN_DIR)/cloc'
	@$(CHMOD) +x '$(BIN_DIR)/cloc'
endif

watch: install .interactive
	# Watch for code changes and rerun the test suite
	@$(call run-shell,$(BUNDLE) exec $(GUARD))

test: \
	test-specs \
	test-style

test-specs: .fetch-cloc
	# Run the whole test suite
	@$(call run-shell,$(BUNDLE) exec $(RAKE) stats spec)

$(TEST_GEMFILES): GEMFILE=$(@:test-%=%)
$(TEST_GEMFILES):
	# Run the whole test suite ($(GEMFILE))
	@$(call run-shell,$(BUNDLE) exec $(APPRAISAL) $(GEMFILE) $(RSPEC))

test-style: \
	test-style-ruby

test-style-ruby:
	# Run the static code analyzer (rubocop)
	@$(call run-shell,$(BUNDLE) exec $(RUBOCOP) -a)

clean:
	# Clean the dependencies
	@$(RM) -rf $(VENDOR_DIR)
	@$(RM) -rf $(GEMFILES_DIR)/vendor
	@$(RM) -rf $(GEMFILES_DIR)/*.lock
	@$(RM) -rf .bundle .yardoc coverage pkg Gemfile.lock doc/api \
		.rspec_status

clean-containers:
	# Clean running containers
ifeq ($(MAKE_ENV),docker)
	@$(COMPOSE) down
endif

clean-images:
	# Clean build images
ifeq ($(MAKE_ENV),docker)
	@-$(DOCKER) images | $(GREP) $(shell basename "`pwd`") \
		| $(AWK) '{ print $$3 }' \
		| $(XARGS) -rn1 $(DOCKER) rmi -f
endif

distclean: clean clean-containers clean-images

shell:
	# Run an interactive shell on the container
	@$(call run-shell,$(BASH) -i)

shell-irb:
	# Run an interactive IRB shell on the container
	@$(call run-shell,bin/console)

docs:
	# Build the API documentation
	@$(call run-shell,$(BUNDLE) exec $(YARD) -q && \
		$(BUNDLE) exec $(YARD) stats --list-undoc --compact)

notes:
	# Print the code statistics (library and test suite)
	@$(call run-shell,$(BUNDLE) exec $(RAKE) notes)

stats:
	# Print all the notes from the code
	@$(call run-shell,$(BUNDLE) exec $(RAKE) stats)

release: .fetch-cloc
	# Release a new gem version
	@$(BUNDLE) exec $(RAKE) release
