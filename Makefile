.PHONY: test lint

test:
	@busted -v -o gtest

lint:
	@luacheck src --std luajit
