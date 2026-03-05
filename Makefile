.PHONY: test-8.3 test-8.4

build-base8.3:
	docker build -f ./alpine.Dockerfile --build-context 'php=docker-image://dunglas/frankenphp:1.11-php8.3-alpine' -t local/frankenphp:1.11-php8.3-alpine --load ./

build8.3: build-base8.3
	docker build -f ./test/demo/Dockerfile --build-context 'php=docker-image://local/frankenphp:1.11-php8.3-alpine' -t local/frankenphp:test-8.3 --load ./test/demo/

start8.3: build8.3
	docker stop frankenphp-test || true
	docker rm frankenphp-test || true
	docker run --name frankenphp-test --tty -p 8000:80 -d -e CADDY_SERVER_HTTP_LOG_LEVEL=info local/frankenphp:test-8.3

test-8.3: start8.3
	sleep 1
	curl localhost:8000
	docker stop frankenphp-test || true
	docker image rm frankenphp:8.3 || true

test-8.4:
	docker build -f ./test/demo/Dockerfile --build-context 'php=docker-image://trucksnl/frankenphp:1.11-php8.4-alpine' -t frankenphp:8.4 ./test/demo/
	docker run --rm --name frankenphp-test -p 8000:80 -d frankenphp:8.4
	sleep 1
	curl localhost:8000
	docker stop frankenphp-test || true
	docker image rm frankenphp:8.4 || true
