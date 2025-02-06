FROM alpine:edge AS build

ARG PRIVOXY_VERSION=4.0.0
ARG PRIVOXY_GIT_URL="https://www.privoxy.org/git/privoxy.git"

ENV BUILD_DIR=/build
RUN mkdir -p "${BUILD_DIR}"
WORKDIR ${BUILD_DIR}

RUN apk --no-cache add \
        bash \
        curl \
        build-base \
        linux-headers \
        ca-certificates \
        perl \
        git \
        autoconf \
        zlib-dev \
        pcre2-dev


RUN set -eux; \
    \
    cd ${BUILD_DIR}; \
    git clone --branch $(echo "${PRIVOXY_VERSION}" | sed 's/\./_/g;s/^/v_/') "${PRIVOXY_GIT_URL}"; \
    cd ${BUILD_DIR}/privoxy; \
    \
    autoheader; \
    autoconf; \
    ./configure \
      --prefix=${BUILD_DIR}/privoxy/dist \
      --enable-static-linking \
      --disable-dynamic-pcre; \
    make -j4; \
    make install; \
    scanelf -R --nobanner -F '%F' ${BUILD_DIR}/privoxy/dist/sbin/ | xargs strip


FROM scratch

LABEL maintainer="Boeboe <boeboe@github.com>" \
    org.label-schema.vcs-url="https://github.com/boeboe/privoxy-scratch.git"

ENV BUILD_DIR=/build

COPY --from=build ${BUILD_DIR}/privoxy/dist/sbin/privoxy /usr/bin/privoxy

CMD ["privoxy"]
