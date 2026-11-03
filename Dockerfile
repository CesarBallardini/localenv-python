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

FROM python:3.14.10-slim@sha256:930e1abba7c4e8f96ed93e8012c35d174d7732752731bbd5e8e757d7ec6f3966

COPY --from=uv /uv /uvx /usr/local/bin/

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
