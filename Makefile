include Make.config

.PHONY: build open init iframes

UNAME = $(shell uname)

dist = dist
devbin = ./node_modules/.bin
browserify = $(devbin)/browserify --t coffeeify
dist/imgs: imgs
	@mkdir -p $(dir $@)
	cp -r $< $@

build: node_modules dist/imgs assets app app.css iframes ExsCheck dist/iframe_check.js dist/checkTests.js

app: $(dist)/app.js
app.css: $(dist)/app.css

assets: font-awesome dist/jquery.js vendor-libs dist/node-event-emitter.js \
		dist/lodash.js

serve:
	cd dist && python -m http.server

font-awesome:
	cp -R ./node_modules/font-awesome dist

define modulize  
	$(browserify) -r $1 >$@
endef

$(dist)/lodash.js:
	@mkdir -p $(dir $@)
	$(call modulize, "lodash")

$(dist)/jquery.js:
	@mkdir -p $(dir $@)
	$(call modulize, "jquery")

$(dist)/node-event-emitter.js:
	@mkdir -p $(dir $@)
	$(call modulize, "node-event-emitter")

$(dist)/ExsCheck.js: ExsCheck.coffee
	$(devbin)/browserify --t coffeeify -r ./ExsCheck.coffee:ExsCheck >$@

$(dist)/checkTests.js: checkTests.coffee
	#coffee -bc $<
	$(devbin)/browserify --t coffeeify -r ./checkTests.coffee:checkTests >$@

$(dist)/%.js: %.coffee
	@mkdir -p $(dir $@)
	$(devbin)/browserify --standalone images --t browserify-css --t coffeeify --debug $< -o $@

ExsCheck: $(dist)/ExsCheck.js

$(dist)/%.css: %.less
	$(devbin)/lessc $< >$@

iframes:
	$(devbin)/jade -P iframes/* -o $(dist)

node_modules: package.json
	npm install

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

vendor-libs:
	$(devbin)/browserify --t coffeeify -r jquery -r react \
									   -r lodash -r reflux >dist/vendor-lib.js
