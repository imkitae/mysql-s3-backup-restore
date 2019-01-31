FROM alpine:latest
LABEL maintainer="KT Kang <kt.kang@ridi.com>"

ARG AWS_CLI_VERSION

RUN apk add --no-cache -v --virtual .build-deps \
    py-pip \
    && apk add -v \
        python \
        mysql-client \
    && pip install --upgrade awscli==${AWS_CLI_VERSION} \
&& apk del -v .build-deps \
&& rm -r /root/.cache \
&& rm /var/cache/apk/*

# PAGER: aws-cli uses 'less -R'. However less with R option is not available in alpine linux
ENV PAGER=more \
    MYSQL_PORT=3306 \
    MYSQL_DUMP_OPTIONS="--quote-names --quick --add-drop-table --add-locks --allow-keywords --disable-keys --extended-insert --single-transaction --create-options --comments --net_buffer_length=16384" \
    S3_PREFIX=backup

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]