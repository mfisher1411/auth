include auth.env

LOCAL_BIN:=$(CURDIR)/bin

LOCAL_MIGRATION_DIR=$(MIGRATION_DIR)
LOCAL_MIGRATION_DSN="host=localhost port=$(PG_PORT) dbname=$(PG_DATABASE_NAME) user=$(PG_USER) password=$(PG_PASSWORD)"

install-golangci-lint:
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.61.0
	

lint:
	$(LOCAL_BIN)/golangci-lint run ./... --config .golangci.pipeline.yaml


install-deps:
	GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.35.2
	GOBIN=$(LOCAL_BIN) go install -mod=mod google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1
	GOBIN=$(LOCAL_BIN) go install github.com/pressly/goose/v3/cmd/goose@v3.23.0


get-deps:
	go get -u google.golang.org/protobuf/cmd/protoc-gen-go
	go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc

generate:
	make generate-user-api

generate-user-api:
	mkdir -p pkg/user_v1
	protoc --proto_path api/user_v1 \
	--go_out=pkg/user_v1 --go_opt=paths=source_relative \
	--plugin=protoc-gen-go=bin/protoc-gen-go \
	--go-grpc_out=pkg/user_v1 --go-grpc_opt=paths=source_relative \
	--plugin=protoc-gen-go-grpc=bin/protoc-gen-go-grpc \
	api/user_v1/user.proto

build:
	GOOS=linux GOARCH=amd64 go build -o service_linux cmd/grpc/main.go

copy-to-server:
	scp service_linux root@45.12.231.86

docker-build-and-push:
	docker buildx build --no-cache --platform linux/amd64 -t <REGESTRY>/test-server:v0.0.1
	docker login -u <USERNAME> -p <PASSWORD> <REGESTRY>
	docker push <REGESTRY>/test-server:v0.0.1

# docker-build-and-push:
# 	docker buildx build --no-cache --platform linux/amd64 -t <REGESTRY>/test-server:v0.0.1
# 	docker login -u <USERNAME> -p <PASSWORD> <REGESTRY>
# 	docker push <REGESTRY>/test-server:v0.0.1

local-migration-status:
	${LOCAL_BIN}/goose -dir $(LOCAL_MIGRATION_DIR) postgres $(PG_DSN) status -v

local-migration-up:
	${LOCAL_BIN}/goose -dir $(LOCAL_MIGRATION_DIR) postgres $(PG_DSN) up -v

local-migration-down:
	${LOCAL_BIN}/goose -dir $(LOCAL_MIGRATION_DIR) postgres $(PG_DSN) down -v	