MEMORY?=64000000 # 8MB by default
TITLE?=Untitled

clean:
	rm -rf dist

build: clean
	mkdir dist && cd src && zip -r ../dist/$(TITLE).love * && cd ..

server: build
	love.js dist/$(TITLE).love dist/$(TITLE) --title $(TITLE) --memory $(MEMORY)
