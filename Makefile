export RELEASE_VERSION	?= $(shell git show -q --format=%h)
export DOCKER_REGISTRY	?= docker.pkg.github.com/ddanurwenda/relecho
export DEPLOY			?= api

all: build start
db-migrate:
	rel migrate
db-rollback:
	rel rollback
gen:
	go generate ./...
build: gen
	go build -o bin/api ./cmd/api
test: gen
	go test -coverprofile=cover.out -race ./...
start:
	export $$(cat .env | grep -v ^\# | xargs) && ./bin/api
docker:
	docker build -t $(DOCKER_REGISTRY)/$(DEPLOY):$(RELEASE_VERSION) -f ./deploy/$(DEPLOY)/Dockerfile .
push:
	docker push $(DOCKER_REGISTRY)/$(DEPLOY):$(RELEASE_VERSION)
