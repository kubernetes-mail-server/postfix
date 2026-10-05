FROM alpine:3.21

ENV TZ=/etc/localtime

RUN set -xe \
    && apk add --no-cache \
            bind-tools \
            postfix postfix-mysql postfix-pcre \
            postsrsd \
            supervisor rsyslog tzdata \
    && echo "Setting the UTC timezone" \
    && cp /usr/share/zoneinfo/UTC /etc/localtime

COPY supervisord-conf /etc/

COPY config /etc/postfix
COPY postsrsd/postsrsd.conf /etc/postsrsd/postsrsd.conf
RUN chmod -R o-rwx /etc/postfix

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 25/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord","--configuration","/etc/supervisord.conf"]
