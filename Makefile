GOFILES_NOVENDOR=$(shell find . -type f -name '*.go' -not -path "./vendor/*")
GO_VERSION=1.12

REGISTRY=registry.cn-hangzhou.aliyuncs.com/shareinto
ROLES=controller
DEV_TAG=dev
RELEASE_TAG=$(shell cat VERSION)

.PHONY: build-dev-images build-go build-bin test lint up down halt suspend resume

build-dev-images: build-bin
	@for role in ${ROLES} ; do \
		docker build -t ${REGISTRY}/sample-$$role:${DEV_TAG} -f dist/images/Dockerfile.$$role dist/images/; \
		docker push ${REGISTRY}/sample-$$role:${DEV_TAG}; \
	done

build-go:
	CGO_ENABLED=0 GOOS=linux go build -o $(PWD)/dist/images/kube-ovn-controller -ldflags "-w -s" -v ./cmd/controller

release: build-go
	@for role in ${ROLES} ; do \
		docker build -t ${REGISTRY}/sample-$$role:${RELEASE_TAG} -f dist/images/Dockerfile.$$role dist/images/; \
		docker push ${REGISTRY}/sample-$$role:${RELEASE_TAG}; \
	done

lint:
	@gofmt -d ${GOFILES_NOVENDOR} 
	@gofmt -l ${GOFILES_NOVENDOR} | read && echo "Code differs from gofmt's style" 1>&2 && exit 1 || true
	@GOOS=linux go vet ./...

test:
	GOOS=linux go test -cover -v ./...