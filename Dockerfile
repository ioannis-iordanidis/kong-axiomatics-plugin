FROM kong:0.13

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh && \
    apk add --no-cache curl && \
    apk add --no-cache gcc musl-dev && \
    apk add --no-cache openssl && \
    apk add --no-cache openssl-dev && \
    rm -rf /var/cache/apk/*

RUN git clone https://github.com/ioannis-iordanidis/kong-hello-world-plugin.git /tmp/jwt \
&& cd /tmp/jwt \
&& git checkout master \
&& mv /tmp/jwt/kong/plugins/kong-plugin-hello-world /usr/local/share/lua/5.1/kong/plugins/kong-plugin-hello-world

ENV KONG_CUSTOM_PLUGINS=kong-plugin-hello-world

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-c", "/usr/local/kong/nginx.conf", "-p", "/usr/local/kong/"]
