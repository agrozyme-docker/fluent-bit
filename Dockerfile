FROM agrozyme/alpine:3.9
COPY rootfs /
WORKDIR /tmp/fluent-bit/build
RUN set +e -uxo pipefail && chmod +x /usr/local/bin/* && /usr/local/bin/docker-build.lua
WORKDIR /
EXPOSE 2020
CMD ["/usr/local/bin/docker-run.lua"]
