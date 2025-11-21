README.md
# 🐳 Multi-Architecture Docker Build & Push using GitHub Actions

This project demonstrates how to build a Docker image for **two CPU architectures** —  
`amd64` and `arm64` — and automatically push them to **two different container registries**:

| Architecture | Registry |
|--------------|----------|
| `amd64`      | Docker Hub |
| `arm64`      | GitHub Container Registry (GHCR) |

---

## 🚀 Features

✔ Build Docker images using GitHub Actions  
✔ Cross-platform build using QEMU  
✔ Push `amd64` builds to Docker Hub  
✔ Push `arm64` builds to GitHub Container Registry  
✔ Auto-tags images using the commit SHA  
✔ Fully automated on `git push` to `main` or any tag like `v1.0`

---

## 🧰 Requirements

### 🔑 GitHub Secrets Needed

| Secret Name | Description |
|-------------|-------------|
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token/password |

> ⚠️ GHCR uses `GITHUB_TOKEN` automatically, so no extra secrets are needed.

---

## 🏗️ Workflow Overview

The workflow uses:

- **docker/setup-qemu-action** — enables cross-architecture building
- **docker/setup-buildx-action** — enables multi-platform buildx
- **docker/login-action** — authenticates to registries
- **docker buildx build** — builds & pushes the image

---

## 🗂️ Project Structure



.
├── Dockerfile
└── .github
└── workflows
└── main.yml


Your Dockerfile can be any valid build definition. Example:

```dockerfile
# Base image
FROM alpine:3.19
RUN echo "Hello Multi-Arch!" > /message.txt
CMD ["cat", "/message.txt"]

🏷️ Tags Naming Convention

The images are pushed with the format:

ghcr.io/<owner>/<repo>:arm64-<short_sha>
docker.io/<dockerhub_user>/<repo>:amd64-<short_sha>


Example:

ghcr.io/najla-art/matrix-project2:arm64-ab12cd34
docker.io/najlaart/matrix-project2:amd64-ab12cd34

🤖 GitHub Workflow (main.yml)
name: Build architecture-specific images and push

on:
  push:
    branches: [ "main" ]
    tags:
      - 'v*'

permissions:
  contents: read
  packages: write

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - arch: linux/arm64
            registry: ghcr.io
            tag_suffix: arm64
          - arch: linux/amd64
            registry: docker.io
            tag_suffix: amd64

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Docker Hub
        if: matrix.registry == 'docker.io'
        uses: docker/login-action@v2
        with:
          registry: docker.io
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Login to GHCR
        if: matrix.registry == 'ghcr.io'
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push (arch-specific)
        env:
          SHORT_SHA: ${{ github.sha }}
        run: |
          set -euo pipefail

          TAG="${SHORT_SHA:0:8}"
          REPO_NAME="${{ github.event.repository.name }}"
          OWNER="${{ github.repository_owner }}"

          if [ "${{ matrix.registry }}" = "ghcr.io" ]; then
            IMAGE="ghcr.io/${OWNER}/${REPO_NAME}:${{ matrix.tag_suffix }}-${TAG}"
            echo "Building for ${{ matrix.arch }} and pushing to ${IMAGE}"
            docker buildx build --platform=${{ matrix.arch }} -f ./Dockerfile -t "${IMAGE}" --push .
          else
            IMAGE="${{ secrets.DOCKERHUB_USERNAME }}/${REPO_NAME}:${{ matrix.tag_suffix }}-${TAG}"
            echo "Building for ${{ matrix.arch }} and pushing to ${IMAGE}"
            docker buildx build --platform=${{ matrix.arch }} -f ./Dockerfile -t "${IMAGE}" --push .
          fi

🎉 Future Enhancements

🔧 Combine the two architectures into a single multi-arch manifest, for example:

docker pull najlaart/matrix-project2:latest


If you want, I can provide a manifest merging workflow too!
