FROM alpine as build

RUN apk add curl autoconf gcc flex bison make bash cmake libtool musl-dev g++ \
    zlib-dev zlib-static \
    tcl tk \
    tcl-dev gettext

ARG GIT_VERSION

RUN curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz -o git_v${GIT_VERSION}.tar.gz

RUN tar zxf git_v${GIT_VERSION}.tar.gz

WORKDIR /git-${GIT_VERSION}

RUN make configure && \
    sed -i 's/qversion/-version/g' configure && \
    ./configure prefix=/dist/git-${GIT_VERSION} LDFLAGS="--static" CFLAGS="${CFLAGS} -static" && \
    cat config.log && \
    make && make install

FROM gcr.io/distroless/static:nonroot
ARG GIT_VERSION
WORKDIR /dist
COPY --from=build /dist/git-${GIT_VERSION}/bin/ /dist
USER nonroot:nonroot

ENTRYPOINT [ "/dist/git" ]
