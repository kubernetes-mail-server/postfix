FROM alpine:3.8

ENV TZ=/etc/localtime
ENV ALPINE_VERSION=3.8
ENV ALPINE_MIRROR=http://nl.alpinelinux.org/alpine

RUN set -xe \
	&& echo ${ALPINE_MIRROR}/v${ALPINE_VERSION}/main > /etc/apk/repositories \
    && echo ${ALPINE_MIRROR}/v${ALPINE_VERSION}/community >> /etc/apk/repositories \
    && echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && cat /etc/apk/repositories \
    && apk add --no-cache \
            bind-tools \
            postfix@edge postfix-mysql@edge postfix-pcre@edge \
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
