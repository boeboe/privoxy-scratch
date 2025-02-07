FROM alpine:edge AS build

ARG PRIVOXY_VERSION=4.0.0
ARG PRIVOXY_GIT_URL="https://www.privoxy.org/git/privoxy.git"

ARG BROTLI_VERSION=1.1.0
ARG BROTLI_GIT_URL="https://github.com/google/brotli.git"

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
        cmake \
        zlib zlib-dev zlib-static \
        pcre2 pcre2-dev \
        openssl openssl-dev openssl-libs-static

RUN set -eux; \
    \
    cd ${BUILD_DIR}; \
    git clone --branch v${BROTLI_VERSION} "${BROTLI_GIT_URL}"; \
    cd ${BUILD_DIR}/brotli; \
    \
    mkdir out; \
    cd out; \
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DCMAKE_C_FLAGS="-static" \
      -DCMAKE_EXE_LINKER_FLAGS="-static" \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_SHARED_LIBS=OFF ; \
    make -j4; \
    make install

RUN set -eux; \
    \
    cd ${BUILD_DIR}; \
    git clone --branch $(echo "${PRIVOXY_VERSION}" | sed 's/\./_/g;s/^/v_/') "${PRIVOXY_GIT_URL}"; \
    cd ${BUILD_DIR}/privoxy; \
    \
    autoheader; \
    autoconf; \
    sed -i 's/LIBS="\$LIBS -lbrotlidec"/LIBS="$LIBS -lbrotlidec -lbrotlienc -lbrotlicommon"/' ./configure; \
    ./configure \
      --prefix=${BUILD_DIR}/privoxy/dist \
      --disable-dynamic-pcre \
      --enable-accept-filter \
      --enable-compression \
      --enable-extended-statistics \
      --enable-external-filters \
      --enable-graceful-termination \
      --enable-no-gifs \
      --enable-pcre-host-patterns \
      --enable-static-linking \
      --enable-strptime-sanity-checks \
      --with-openssl \
      --with-brotli ; \
    make -j4; \
    make install; \
    scanelf -R --nobanner -F '%F' ${BUILD_DIR}/privoxy/dist/sbin/ | xargs strip


FROM scratch

LABEL maintainer="Boeboe <boeboe@github.com>" \
    org.label-schema.vcs-url="https://github.com/boeboe/privoxy-scratch.git"

ENV BUILD_DIR=/build
COPY --from=build ${BUILD_DIR}/privoxy/dist/sbin/privoxy /usr/bin/privoxy

# Expose Privoxy Port
EXPOSE 8118

CMD ["privoxy", "--no-daemon", "/etc/privoxy/privoxy.conf"]
