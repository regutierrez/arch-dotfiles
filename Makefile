SHELL := /bin/sh

TARGET ?= $(HOME)
ROOT := $(CURDIR)
HOME_DIR := $(ROOT)/home

# Link top-level home entries directly, except .config. For .config, link each
# tracked file/dir entry into the existing ~/.config tree so local app files are
# not clobbered.
HOME_ENTRIES := $(shell find "$(HOME_DIR)" -mindepth 1 -maxdepth 1 ! -name '.config' -printf '%f\n' | sort)
CONFIG_FILES := $(shell [ -d "$(HOME_DIR)/.config" ] && find "$(HOME_DIR)/.config" -type f -printf '%P\n' | sort)

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
	@mkdir -p "$(TARGET)" "$(TARGET)/.config"
	@for entry in $(HOME_ENTRIES); do \
		ln -sfnT "$(HOME_DIR)/$$entry" "$(TARGET)/$$entry" && \
		echo "linked $(TARGET)/$$entry -> $(HOME_DIR)/$$entry"; \
	done
	@for file in $(CONFIG_FILES); do \
		src="$(HOME_DIR)/.config/$$file"; \
		dst="$(TARGET)/.config/$$file"; \
		[ "$$(readlink -f "$$src")" = "$$(readlink -f "$$dst" 2>/dev/null)" ] && continue; \
		mkdir -p "$$(dirname "$$dst")"; \
		ln -sfn "$$src" "$$dst" && \
		echo "linked $$dst -> $$src"; \
	done

delete:
	@for entry in $(HOME_ENTRIES); do \
		[ ! -L "$(TARGET)/$$entry" ] || rm "$(TARGET)/$$entry"; \
	done
	@for file in $(CONFIG_FILES); do \
		[ ! -L "$(TARGET)/.config/$$file" ] || rm "$(TARGET)/.config/$$file"; \
	done

check:
	@for entry in $(HOME_ENTRIES); do \
		echo "ln -sfnT $(HOME_DIR)/$$entry $(TARGET)/$$entry"; \
	done
	@for file in $(CONFIG_FILES); do \
		echo "mkdir -p $$(dirname $(TARGET)/.config/$$file) && ln -sfn $(HOME_DIR)/.config/$$file $(TARGET)/.config/$$file"; \
	done

list:
	@for entry in $(HOME_ENTRIES); do echo "$(TARGET)/$$entry"; done
	@for file in $(CONFIG_FILES); do echo "$(TARGET)/.config/$$file"; done
