.PHONY: help
help: ## Display this help messages
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

compile: ## Please re-compile when you change init.el
	emacs --batch -f batch-byte-compile init.el
