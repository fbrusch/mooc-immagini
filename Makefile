include Make.config

dist/immagini.html: immagini.jade
	node_modules/.bin/jade -P immagini.jade -o dist

.PHONY: build open init iframes

UNAME = $(shell uname)


dist = dist
#livereload_port = 45870
devbin = ./node_modules/.bin
browserify = $(devbin)/browserify --t coffeeify

build: app index app.css iframes ExsCheck

index: $(dist)/index.html
app: $(dist)/app.js
app.css: $(dist)/app.css

assets: font-awesome

font-awesome:
	cp -R ./node_modules/font-awesome dist

define modulize  
	$(browserify) -r $1 >$@
endef

$(dist)/lodash.js:
	$(call modulize, "lodash")

$(dist)/jquery.js:
	$(call modulize, "jquery")

$(dist)/node-event-emitter.js:
	$(call modulize, "node-event-emitter")

$(dist)/ExsCheck.js: ExsCheck.coffee
	#coffee -bc $<
	$(devbin)/browserify --t coffeeify -r ./ExsCheck.coffee:ExsCheck >$@

ExsCheck: $(dist)/ExsCheck.js
$(dist)/app.css: app.less
	$(devbin)/lessc $< >$@

iframes:
	jade -P iframes/* -o $(dist)

init: 
	git checkout -b master
	mkdir dist
	npm install

$(dist)/app.js: app.coffee
	$(devbin)/browserify --standalone images --t browserify-css --t coffeeify --debug $< -o $@

$(dist)/index.html: index.jade
	$(devbin)/jade -O \
		"{livereloadUrl:'http://localhost:$(livereload_port)/livereload.js'}" \
		-P index.jade -o dist

open: $(dist)/index.html
ifeq ($(UNAME), Linux)
	xdg-open $<
else
	open $<
endif

watch:
	$(devbin)/nodemon -w iframes -w . --exec "make build || true" -e "jade coffee less"

livereload:
	$(devbin)/livereload ./dist -p $(livereload_port)

