FROM alpine:latest

ENV TZ=/etc/localtime

RUN set -xe \
    && apk add --no-cache \
            bind-tools \
            postfix postfix-mysql postfix-pcre \
            supervisor rsyslog tzdata \
    && echo "Setting the UTC timezone" \
    && cp /usr/share/zoneinfo/UTC /etc/localtime

COPY supervisord-conf /etc/

COPY config /etc/postfix
RUN chmod -R o-rwx /etc/postfix

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 25/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord","--configuration","/etc/supervisord.conf"]
