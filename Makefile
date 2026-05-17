SHELL := /bin/sh

STOW ?= stow
TARGET ?= $(HOME)

# Every top-level directory is treated as a stow package.
PACKAGES := $(shell find . -mindepth 1 -maxdepth 1 -type d \
	-not -name '.git' \
	-not -name '.github' \
	-printf '%f\n' | sort)

.PHONY: help install delete restow adopt list check

help:
	@echo "Usage: make <target> [PACKAGES=\"pkg1 pkg2\"] [TARGET=/path]"
	@echo
	@echo "Targets:"
	@echo "  install  Symlink packages into TARGET; default TARGET=$(HOME)"
	@echo "  delete   Remove stowed symlinks from TARGET"
	@echo "  restow   Recreate symlinks in TARGET"
	@echo "  adopt    Adopt existing files from TARGET into this repo, then stow"
	@echo "  list     Show detected packages"
	@echo "  check    Preview what install would do"

install:
	$(STOW) --target="$(TARGET)" $(PACKAGES)

delete:
	$(STOW) --delete --target="$(TARGET)" $(PACKAGES)

restow:
	$(STOW) --restow --target="$(TARGET)" $(PACKAGES)

adopt:
	$(STOW) --adopt --target="$(TARGET)" $(PACKAGES)

check:
	$(STOW) --no --verbose --target="$(TARGET)" $(PACKAGES)

list:
	@printf '%s\n' $(PACKAGES)
