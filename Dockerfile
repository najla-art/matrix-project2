FROM alpine:3.18
# Example: multi-arch-compatible simple image
RUN apk add --no-cache bash curl
COPY ./app /app
WORKDIR /app
CMD ["sh", "-c", "echo Hello from $(uname -m); sleep 3600"]
