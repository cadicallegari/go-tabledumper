version     ?= latest
tabledumperimg = myregistry/tabledumper:$(version)
devimg       = tabledumperdev
GOPATH      ?= $(HOME)/go
packagename  = $(shell pwd | sed "s:"$(GOPATH)"/src/::")
workdir      = /go/src/$(packagename)
runargs      = --rm -v `pwd`:$(workdir) --workdir $(workdir) $(devimg)
runshell     = docker run $(runargs)
runcmd       = docker run -ti $(runargs)
run-dev      = docker-compose run --rm $(devimg)
gitversion   = $(version)

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Variable '$*' not set"; \
		exit 1; \
	fi

release: guard-version publish
	git tag -a $(version) -m "Generated release "$(version)
	git push origin $(version)

publish: image
	docker push $(tabledumperimg)

image: build
	docker build -t $(tabledumperimg) .

imagedev:
	docker build -t $(devimg) -f ./hack/Dockerfile.dev .

vendor: imagedev
	$(runcmd) ./hack/vendor.sh
	chown -R $(USER):$(USER) ./vendor
	chown -R $(USER):$(USER) ./Godeps

build: imagedev
	$(runcmd) go build -v -ldflags "-X main.Version=$(gitversion)" -o ./cmd/tabledumper/tabledumper ./cmd/tabledumper/main.go

analyze:
	$(runcmd) ./hack/analyze.sh

check: imagedev
	$(run-dev) ./hack/check.sh $(pkg) $(test)

check-integration: compose-build
	$(run-dev) ./hack/check-integration.sh $(test)

compose-build:
	docker-compose build

coverage: imagedev
	$(runcmd) ./hack/coverage.sh

coverage-show: coverage
	xdg-open fullcov.html

shell: imagedev
	$(runshell)

run: build
	$(run-dev) ./cmd/tabledumper/tabledumper

cleanup:
	docker-compose down
