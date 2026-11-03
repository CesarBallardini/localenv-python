# Base image for the devcontainer: the toolchain, not the project.
#
# The project source is bind-mounted by the devcontainer and installed by
# `make install` on create, so the image deliberately does not COPY the source
# -- which also avoids needing the git history that uv-dynamic-versioning reads
# to derive the version.
FROM python:3.14.10-slim

# uv comes from its own published image so the version here, the one in
# .github/actions/install-uv and the one developers run locally stay in step.
COPY --from=ghcr.io/astral-sh/uv:0.13.7 /uv /uvx /usr/local/bin/

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
