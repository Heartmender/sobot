build: so
	nimble build

debug: so
	nim c src/sobot.nim

so:
	make -C modules

.PHONY: web
web:
	cp -vrf web/* /home/tulpa.im/domains/logmon.tulpa.im/public_html/
