build: so
	nimble build

debug: so
	nim c src/sobot.nim

so:
	make -C modules
