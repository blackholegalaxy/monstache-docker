FROM golang:1.12.6-alpine3.10 as builder

ENV MONSTACHE_VERSION=v6.3.1

COPY go.mod /cache-module/go.mod
COPY go.sum /cache-module/go.sum

RUN apk add --no-cache gcc git musl-dev make zip

WORKDIR /cache-module
RUN go mod download
RUN git clone https://github.com/rwynn/monstache.git /app

WORKDIR /app
RUN rm -rf /cache-module
RUN git checkout $MONSTACHE_VERSION
RUN go mod download
RUN make release

FROM alpine:3.10.0

RUN apk --no-cache add ca-certificates

ENTRYPOINT ["/bin/monstache"]

COPY --from=builder /app/build/linux-amd64/monstache /bin/monstache
