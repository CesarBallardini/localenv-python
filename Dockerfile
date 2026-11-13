# Base image for the devcontainer: the toolchain, not the project.
#
# The project source is bind-mounted by the devcontainer and installed by
# `make install` on create, so the image deliberately does not COPY the source
# -- which also avoids needing the git history that uv-dynamic-versioning reads
# to derive the version.

# uv comes from its own published image so the version here, the one in
# .github/actions/install-uv and the one developers run locally stay in step.
# A named stage, not COPY --from=<image>: Dependabot only reads FROM lines.
FROM ghcr.io/astral-sh/uv:0.13.7@sha256:96f40d3904aad8d0bd010539001d36c8e2188b981e1334471a90c4a1d93bb490 AS uv

# Node for pyright. Without one on PATH, pyright installs it through nodeenv, which
# takes the newest entry in Node's index, and a 27.0.0 alpha crashes it. No wheel
# on PyPI reaches the eMudhra floor, so pyright[nodejs] is not an option.
FROM node:24.22.2-slim@sha256:c86ecead9e55a5210ac1727de38a4ca840bf03dcaf34dc9749addbf383b1920c AS node

# The scanners `make security` runs, built here because the published binaries sit
# below the eMudhra floor: gitleaks on Go 1.24.13 and OSV-Scanner on Go 1.27.0. Go's
# checksum database fixes what these tags resolve to. Dependabot cannot read a RUN
# line, so a test holds both versions to security.yml and the gitleaks hook.
FROM golang:1.27.3-alpine@sha256:fa3d596898d9f126af7c01d14ee7597bab3f39cccf392ef36b69fe77cd681f18 AS scanners
ENV CGO_ENABLED=0 GOBIN=/scanners
RUN go install github.com/zricethezav/gitleaks/v8@v8.30.1
RUN go install github.com/google/osv-scanner/v2/cmd/osv-scanner@v2.7.0

FROM python:3.14.10-slim@sha256:930e1abba7c4e8f96ed93e8012c35d174d7732752731bbd5e8e757d7ec6f3966

COPY --from=uv /uv /uvx /usr/local/bin/
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=scanners /scanners/ /usr/local/bin/

# git and make for the workflow itself. No Debian Go or Node: they sit below the
# releases that stop trusting the compromised eMudhra certificates, so pre-commit
# fetches current ones for the gitleaks and markdown-link-check hooks. The Node it
# fetches links libatomic1.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      libatomic1 \
      make \
 && rm -rf /var/lib/apt/lists/*

# Copy rather than hardlink: the workspace is a bind mount, on a different
# filesystem from the image layers.
ENV UV_LINK_MODE=copy

WORKDIR /workspace
