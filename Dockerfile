FROM alpine:3.18
RUN apk add --no-cache bash curl
COPY . /app
WORKDIR /app
CMD ["sh", "-c", "echo Hello from $(uname -m); sleep 3600"]
