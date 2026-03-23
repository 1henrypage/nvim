STYLUA := $(shell command -v stylua 2>/dev/null || echo ~/.local/share/nvim/mason/bin/stylua)

fmt:
	$(STYLUA) lua/

check:
	$(STYLUA) --check lua/
