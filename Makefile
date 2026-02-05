.PHONY: test-8.3 test-8.4

test-8.3:
	docker build -f ./test/demo/Dockerfile --build-context 'php=docker-image://trucksnl/frankenphp:1.11-php8.3-alpine' -t frankenphp:8.3 ./test/demo/
	docker run --rm --name frankenphp-test -p 8000:80 -d frankenphp:8.3
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
