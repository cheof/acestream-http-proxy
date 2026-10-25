# syntax=docker/dockerfile:1

FROM ubuntu:22.04

LABEL \
    maintainer="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.title="acestream-http-proxy" \
    org.opencontainers.image.description="Stream AceStream sources without needing to install AceStream player" \
    org.opencontainers.image.authors="Martin Bjeldbak Madsen <me@martinbjeldbak.com>" \
    org.opencontainers.image.url="https://github.com/martinbjeldbak/acestream-http-proxy" \
    org.opencontainers.image.vendor="https://martinbjeldbak.com"

ENV PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_NO_CACHE=true \
    UV_SYSTEM_PYTHON=true \
    PYTHON_EGG_CACHE=/.cache

ENV VERSION="3.2.11_ubuntu_22.04_x86_64_py3.10" \
    ALLOW_REMOTE_ACCESS="yes" \
    EXTRA_FLAGS=''

ENV NO_AT_BRIDGE=1
ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

USER root
WORKDIR /app

COPY acestream_${VERSION}.tar.gz .
# hadolint ignore=DL4006,DL3008,DL3013
RUN \
    apt-get update \
    && \
    apt-get upgrade -y \
    && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        bash \
        ca-certificates \
        catatonit \
        curl \
        nano \
        libgirepository1.0-dev \
        python3.10 python3-pip libpython3.10 \
        dbus-x11 locales \
        python3-gi gir1.2-gtk-3.0 gir1.2-appindicator3-0.1 \
    && locale-gen en_US.UTF-8 \
    && groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid 1000 -m appuser \
    && mkdir -p /app \
    && mkdir -p /.cache \
    && tar xzf acestream_${VERSION}.tar.gz \
    && rm acestream_${VERSION}.tar.gz \
    && pip install uv \
    && uv pip install --requirement /app/requirements.txt \
    && chown -R appuser:appuser /.cache /app && chmod -R 755 /app \
    && pip uninstall --yes uv \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/

COPY entrypoint.sh /

USER appuser

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]

EXPOSE 6878/tcp
EXPOSE 6000/tcp

