FROM golang:1.23.4-alpine3.21 AS builder
COPY . /github.com/mfisher1411/auth/source/
WORKDIR /github.com/mfisher1411/auth/source/

RUN go mod download
RUN go build -o ./bin/auth_server cmd/grpc_server/main.go


FROM alpine:latest


WORKDIR /root/
COPY --from=builder /github.com/mfisher1411/auth/source/bin/auth_server .

CMD ["./auth_server"]