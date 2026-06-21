SHELL := /bin/sh

TARGET ?= $(HOME)
ROOT := $(CURDIR)
HOME_DIR := $(ROOT)/home

# Directories merged file-by-file into the existing tree (not symlinked whole).
MERGE_DIRS := .config .pi

# Track only hidden top-level files/dirs and ignore directories that are merged
# file-by-file below.
HOME_ENTRIES := $(shell \
	find "$(HOME_DIR)" -mindepth 1 -maxdepth 1 -name '.*' \
	$(foreach d,$(MERGE_DIRS),! -name '$d') -printf '%f\n' | sort)
CONFIG_FILES := $(shell find "$(HOME_DIR)/.config" -type f -printf '%P\n' 2>/dev/null | sort)
DOTPI_FILES  := $(shell find "$(HOME_DIR)/.pi"     -type f -printf '%P\n' 2>/dev/null | sort)

.PHONY: help install delete list check

help:
	@echo "Usage: make <target> [TARGET=/path]"
	@echo
	@echo "Targets:"
	@echo "  install  Symlink tracked home files into TARGET; default TARGET=$(HOME)"
	@echo "  delete   Remove symlinks created by install"
	@echo "  list     Show links that would be managed"
	@echo "  check    Preview install commands"

install:
	@mkdir -p "$(TARGET)" $(foreach d,$(MERGE_DIRS),"$(TARGET)/$d")
	@for entry in $(HOME_ENTRIES); do \
		src="$(HOME_DIR)/$$entry"; \
		dst="$(TARGET)/$$entry"; \
		if [ "$$src" = "$$dst" ]; then \
			echo "skip self-target: $$dst"; \
			continue; \
		fi; \
		[ -L "$$dst" ] && [ "$$(readlink -f "$$dst" 2>/dev/null)" = "$$(readlink -f "$$src")" ] && continue; \
		ln -sfnT "$$src" "$$dst" && echo "linked $$dst -> $$src"; \
	done
	@for file in $(CONFIG_FILES); do \
		src="$(HOME_DIR)/.config/$$file"; \
		dst="$(TARGET)/.config/$$file"; \
		if [ "$$src" = "$$dst" ]; then \
			echo "skip self-target: $$dst"; \
			continue; \
		fi; \
		[ -L "$$dst" ] && [ "$$(readlink -f "$$dst" 2>/dev/null)" = "$$(readlink -f "$$src")" ] && continue; \
		mkdir -p "$$(dirname "$$dst")"; \
		if [ -e "$$dst" ] && [ ! -L "$$dst" ] && [ ! -f "$$dst" ]; then \
			echo "skip $$dst: destination is not a file/link" >&2; \
			continue; \
		fi; \
		[ -e "$$dst" ] && rm -f "$$dst"; \
		ln -s "$$src" "$$dst" && echo "linked $$dst -> $$src"; \
	done
	@for file in $(DOTPI_FILES); do \
		src="$(HOME_DIR)/.pi/$$file"; \
		dst="$(TARGET)/.pi/$$file"; \
		if [ "$$src" = "$$dst" ]; then \
			echo "skip self-target: $$dst"; \
			continue; \
		fi; \
		[ -L "$$dst" ] && [ "$$(readlink -f "$$dst" 2>/dev/null)" = "$$(readlink -f "$$src")" ] && continue; \
		mkdir -p "$$(dirname "$$dst")"; \
		if [ -e "$$dst" ] && [ ! -L "$$dst" ] && [ ! -f "$$dst" ]; then \
			echo "skip $$dst: destination is not a file/link" >&2; \
			continue; \
		fi; \
		[ -e "$$dst" ] && rm -f "$$dst"; \
		ln -s "$$src" "$$dst" && echo "linked $$dst -> $$src"; \
	done

delete:
	@for entry in $(HOME_ENTRIES); do \
		[ ! -L "$(TARGET)/$$entry" ] || rm "$(TARGET)/$$entry"; \
	done
	@for file in $(CONFIG_FILES); do \
		[ ! -L "$(TARGET)/.config/$$file" ] || rm "$(TARGET)/.config/$$file"; \
	done
	@for file in $(DOTPI_FILES); do \
		[ ! -L "$(TARGET)/.pi/$$file" ] || rm "$(TARGET)/.pi/$$file"; \
	done

check:
	@for entry in $(HOME_ENTRIES); do \
		echo "ln -sfnT $(HOME_DIR)/$$entry $(TARGET)/$$entry"; \
	done
	@for file in $(CONFIG_FILES); do \
		echo "mkdir -p $$(dirname $(TARGET)/.config/$$file) && ln -sf $(HOME_DIR)/.config/$$file $(TARGET)/.config/$$file"; \
	done
	@for file in $(DOTPI_FILES); do \
		echo "mkdir -p $$(dirname $(TARGET)/.pi/$$file) && ln -sf $(HOME_DIR)/.pi/$$file $(TARGET)/.pi/$$file"; \
	done

list:
	@for entry in $(HOME_ENTRIES); do echo "$(TARGET)/$$entry"; done
	@for file in $(CONFIG_FILES); do echo "$(TARGET)/.config/$$file"; done
	@for file in $(DOTPI_FILES); do echo "$(TARGET)/.pi/$$file"; done
