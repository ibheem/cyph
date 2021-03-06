#!/bin/bash


cd $(cd "$(dirname "$0")" ; pwd)/..
dir="$PWD"


./commands/keycache.sh

mkdir -p ~/lib/js ~/tmplib/js
cd ~/tmplib/js


read -r -d '' modules <<- EOM
	@angular/animations
	@angular/cdk
	@angular/cli
	@angular/common
	@angular/compiler
	@angular/compiler-cli
	@angular/core
	@angular/flex-layout@https://github.com/buu700/flex-layout-tmp
	@angular/forms
	@angular/http
	@angular/material
	@angular/platform-browser
	@angular/platform-browser-dynamic
	@angular/platform-server
	@angular/platform-webworker
	@angular/platform-webworker-dynamic
	@angular/router
	@angular/service-worker
	@compodoc/compodoc
	@covalent/core
	@covalent/dynamic-forms
	@covalent/highlight
	@covalent/http
	@covalent/markdown
	@google-cloud/storage
	@ngrx/core
	@ngrx/effects
	@ngrx/router-store
	@ngrx/store
	@ngrx/store-devtools
	@ngtools/webpack
	@types/braintree-web
	@types/dompurify
	@types/dropzone
	@types/file-saver
	@types/html-to-text
	@types/jasmine
	@types/jquery@^2
	@types/jspdf
	@types/lodash
	@types/long
	@types/markdown-it
	@types/msgpack-lite
	@types/node
	@types/pdfkit
	@types/quill
	@types/stacktrace-js
	angular-speed-dial
	angular-ssr
	angular2-template-loader
	angular2-text-mask
	animate.css@https://github.com/daneden/animate.css
	animated-scroll-to
	awesome-typescript-loader
	babel-core
	babel-loader
	babel-preset-env
	babel-preset-es2015
	bourbon@4.2.7
	braintree-web
	braintree-web-drop-in
	check-tslint-all
	cheerio
	clean-css-cli
	clipboard-polyfill
	codelyzer
	comlinkjs
	copy-webpack-plugin
	core-js
	css-loader
	d3
	datauri
	dompurify
	dragula
	dropzone
	extract-text-webpack-plugin
	fast-crc32c
	faye-websocket
	fg-loadcss
	file-loader
	file-saver
	firebase
	firebase-admin
	firebase-functions
	firebase-server
	firebase-tools
	glob
	google-closure-compiler
	granim
	gulp
	hammerjs
	highlight.js
	html-loader
	html-minifier
	html-to-text
	htmlencode
	htmllint
	image-type
	immutable@rc
	interact.js
	jasmine-core
	jasmine-spec-reporter
	jquery
	jquery.appear@https://github.com/morr/jquery.appear
	jspdf
	karma
	karma-chrome-launcher
	karma-cli
	karma-coverage-istanbul-reporter
	karma-jasmine
	karma-jasmine-html-reporter
	konami-code.js
	lazy
	libsodium
	libsodium-sumo
	libsodium-wrappers
	libsodium-wrappers-sumo
	localforage
	lodash
	long
	lunr
	lz4
	markdown-it
	markdown-it-emoji
	markdown-it-sup
	mceliece
	microlight-string
	mkdirp
	moment
	msgpack-lite
	nativescript
	nativescript-angular
	nativescript-css-loader
	nativescript-dev-typescript
	nativescript-dev-webpack
	nativescript-theme-core
	ng2-fittext
	ng2-pdf-viewer
	ng2-truncate
	node-fetch
	node-sass
	notify-cli
	ntru
	od-virtualscroll@https://github.com/buu700/od-virtualscroll-tmp
	parchment
	pdfkit
	prepack
	prepack-webpack-plugin
	primeng
	protobufjs
	protractor
	puppeteer
	quill
	quill-delta
	quill-delta-to-html
	raw-loader
	read
	reflect-metadata
	request
	resize-observer-polyfill
	resolve-url-loader
	retire
	rlwe
	rsvp
	rxjs@5.5.2
	rxjs-tslint-rules
	sass-loader
	script-ext-html-webpack-plugin
	sidh
	simplewebrtc
	sodiumutil
	sphincs
	stacktrace-js
	style-loader
	stylelint
	stylelint-scss
	supersphincs
	tab-indent
	text-mask-addons
	textillate
	tns-android
	tns-core-modules@next
	tns-core-modules-widgets
	tns-ios
	tns-platform-declarations
	to-markdown
	ts-loader
	ts-node
	tslint
	tslint-microsoft-contrib
	tsutils
	typedoc
	typescript@2.4.2
	u2f-api-polyfill
	uglify-es
	uglifyjs-webpack-plugin
	unsemantic
	url-loader
	web-animations-js
	webpack
	webpack-closure-compiler
	webpack-sources
	webrtc-adapter
	webrtcsupport@https://github.com/buu700/webrtcsupport
	whatwg-fetch
	wowjs
	xkcd-passphrase
	zombie
	zone.js
	$(cat ${dir}/native/plugins.list)
EOM


# Temporary workaround for flat dependencies pending https://github.com/yarnpkg/yarn/issues/1658

cd ..
yarn add compare-versions
cd -

script -fc "
	while [ ! -f yarn.done ] ; do
		answer=\"\$(node -e 'console.log(
			(
				(
					fs.readFileSync(\"yarn.out\").
						toString().
						split(\"Unable to find a suitable version\")[1]
					|| \"\"
				).
					match(/resolved to \".*?\"/g)
				|| []
			).
				map((s, i) => ({index: i + 1, version: s.split(\"\\\"\")[1]})).
				reduce(
					(a, b) => require(\"compare-versions\")(
						a.version,
						b.version
					) === 1 ?
						a :
						b
					,
					{index: \"\", version: \"0\"}
				).index
		)')\"

		if [ \"\${answer}\" ] ; then
			echo > yarn.out
			echo \"\${answer}\"
		fi
	done | bash -c '
		yarn add \
			--flat \
			--ignore-engines \
			--ignore-platform \
			--ignore-scripts \
			--non-interactive \
			$(echo "${modules}" | tr '\n' ' ') \
		|| \
			touch yarn.failure

		touch yarn.done
	'
" yarn.out

if [ -f yarn.failure ] ; then
	exit 1
fi

rm -rf ../node_modules ../package.json ../yarn.lock yarn.failure yarn.out


cp yarn.lock package.json ~/lib/js/

cat node_modules/tslint/package.json | grep -v tslint-test-config-non-relative > package.json.new
mv package.json.new node_modules/tslint/package.json

cd ~/lib/js

# Temporarily skip libsodium update pending further investigation
if [ true ] ; then
	cp -a "${dir}/shared/lib/js/libsodium" ./
else

${dir}/commands/libclone.sh https://github.com/jedisct1/libsodium.js libsodium.build
cd libsodium.build

rm -rf libsodium
git clone --depth 1 --recursive https://github.com/jedisct1/libsodium

cat > wrapper/symbols/crypto_stream_chacha20.json << EOM
{
	"name": "crypto_stream_chacha20",
	"type": "function",
	"inputs": [
		{
			"name": "outLength",
			"type": "uint"
		},
		{
			"name": "key",
			"type": "buf",
			"size": "libsodium._crypto_stream_chacha20_keybytes()"
		},
		{
			"name": "nonce",
			"type": "buf",
			"size": "libsodium._crypto_stream_chacha20_noncebytes()"
		}
	],
	"outputs": [
		{
			"name": "out",
			"type": "buf",
			"size": "outLength"
		}
	],
	"target": "libsodium._crypto_stream_chacha20(out_address, outLength, 0, nonce_address, key_address) | 0",
	"expect": "=== 0",
	"return": "_format_output(out, outputFormat)"
}
EOM
cat > wrapper/symbols/crypto_box_curve25519xchacha20poly1305_keypair.json << EOM
{
	"name": "crypto_box_curve25519xchacha20poly1305_keypair",
	"type": "function",
	"inputs": [],
	"outputs": [
		{
			"type": "buf",
			"size": "libsodium._crypto_box_curve25519xchacha20poly1305_publickeybytes()",
			"name": "publicKey"
		},
		{
			"type": "buf",
			"size": "libsodium._crypto_box_curve25519xchacha20poly1305_secretkeybytes()",
			"name": "secretKey"
		}
	],
	"target": "libsodium._crypto_box_curve25519xchacha20poly1305_keypair(publicKey_address, secretKey_address) | 0",
	"expect": "=== 0",
	"return": "_format_output({publicKey: publicKey, privateKey: secretKey, keyType: \"curve25519\"}, outputFormat)"
}
EOM
cat > wrapper/symbols/crypto_box_curve25519xchacha20poly1305_seal.json << EOM
{
	"name": "crypto_box_curve25519xchacha20poly1305_seal",
	"type": "function",
	"inputs": [
		{
			"name": "message",
			"type": "unsized_buf"
		},
		{
			"name": "publicKey",
			"type": "buf",
			"size": "libsodium._crypto_box_curve25519xchacha20poly1305_publickeybytes()"
		}
	],
	"outputs": [
		{
			"name": "ciphertext",
			"type": "buf",
			"size": "message_length + libsodium._crypto_box_curve25519xchacha20poly1305_sealbytes()"
		}
	],
	"target": "libsodium._crypto_box_curve25519xchacha20poly1305_seal(ciphertext_address, message_address, message_length, 0, publicKey_address) | 0",
	"expect": "=== 0",
	"return": "_format_output(ciphertext, outputFormat)"
}
EOM
cat > wrapper/symbols/crypto_box_curve25519xchacha20poly1305_seal_open.json << EOM
{
	"name": "crypto_box_curve25519xchacha20poly1305_seal_open",
	"type": "function",
	"inputs": [
		{
			"name": "ciphertext",
			"type": "unsized_buf"
		},
		{
			"name": "publicKey",
			"type": "buf",
			"size": "libsodium._crypto_box_curve25519xchacha20poly1305_publickeybytes()"
		},
		{
			"name": "secretKey",
			"type": "buf",
			"size": "libsodium._crypto_box_curve25519xchacha20poly1305_secretkeybytes()"
		}
	],
	"outputs": [
		{
			"name": "plaintext",
			"type": "buf",
			"size": "ciphertext_length - libsodium._crypto_box_curve25519xchacha20poly1305_sealbytes()"
		}
	],
	"target": "libsodium._crypto_box_curve25519xchacha20poly1305_seal_open(plaintext_address, ciphertext_address, ciphertext_length, 0, publicKey_address, secretKey_address) | 0",
	"expect": "=== 0",
	"return": "_format_output(plaintext, outputFormat)"
}
EOM

node -e '
	const constants	= JSON.parse(fs.readFileSync("wrapper/constants.json").toString());
	fs.writeFileSync("wrapper/constants.json", JSON.stringify(constants.concat([
		{"name": "crypto_box_curve25519xchacha20poly1305_NONCEBYTES", "type": "uint"},
		{"name": "crypto_box_curve25519xchacha20poly1305_PUBLICKEYBYTES", "type": "uint"},
		{"name": "crypto_box_curve25519xchacha20poly1305_SECRETKEYBYTES", "type": "uint"}
	])));
'

cat Makefile | perl -pe 's/^(\s+)ln /\1ln -f /g' > Makefile.new
mv Makefile.new Makefile
# sed -i 's|TOTAL_MEMORY_SUMO=35000000|TOTAL_MEMORY_SUMO=150000000|g' libsodium/dist-build/emscripten.sh
make
find dist -type f -name '*.min.js' -exec bash -c 'mv {} "$(echo "{}" | sed "s|\.min||")"' \;
find dist -type f -not -name '*.js' -exec rm {} \;
cd ..
mkdir libsodium
mv libsodium.build/dist libsodium/
rm -rf libsodium.build

fi


cd "${dir}"
rm -rf shared/lib
mv ~/lib shared/
rm -rf ~/tmplib

./commands/getlibs.sh
./commands/commit.sh updatelibs
