FROM alpine:3.18
RUN apk add --no-cache bash curl
COPY . /app
WORKDIR /app
