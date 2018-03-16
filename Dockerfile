FROM debian:latest

ARG TASKD_VERSION="1.1.0"

RUN apt-get update -qq && \
    apt-get install -qqy g++ libgnutls28-dev uuid-dev cmake gnutls-bin curl && \
    addgroup --system --gid 199 taskd && \
    adduser --system --gid 199 --uid 199 taskd && \
    mkdir /src && \
    cd /src && \
    curl -LO "https://github.com/GothenburgBitFactory/taskserver/archive/v${TASKD_VERSION}.tar.gz" && \
    tar -xzf "v${TASKD_VERSION}.tar.gz" && \
    cd "taskserver-${TASKD_VERSION}" && \
    cmake -DCMAKE_BUILD_TYPE=release . && \
    make && \
    make install && \
    cd / && \
    rm -rf /src && \
    apt-get remove -qqy curl cmake g++ && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /tasks && chown taskd:taskd /tasks
VOLUME /tasks

COPY entrypoint.sh /

USER taskd
ENV TASKDDATA=/tasks

EXPOSE 7358

CMD /entrypoint.sh
