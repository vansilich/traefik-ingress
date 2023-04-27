# syntax=docker/dockerfile:1.3

FROM traefik:v3.0

RUN set -x \
    && mkdir -p \
      ./etc/ssl \
      ./etc/traefik/certs \
      ./bin \
      ./tmp \
    && chmod 777 ./tmp \
    && mv /usr/local/bin/traefik ./bin/traefik \
    && chmod 755 ./bin/traefik \
    && chown -c 0:0 ./bin/traefik

# install curl for healthcheck
COPY --from=tarampampam/curl:7.87.0 /bin/curl ./bin/curl

# copy configs...
COPY ./traefik/configs/traefik.yaml /etc/traefik/traefik.yaml
COPY ./traefik/configs/dynamic /etc/traefik/dynamic

# ...and plugins
COPY ./traefik/plugins /opt/traefik/plugins-local/src

EXPOSE "80/tcp" "443/tcp"

# docs: <https://docs.docker.com/engine/reference/builder/#healthcheck>
HEALTHCHECK --interval=5s --timeout=3s --start-period=1s CMD [ \
    "/bin/curl", "--fail", "http://127.0.0.1:81/ping" \
]

ENTRYPOINT ["/bin/traefik"]
