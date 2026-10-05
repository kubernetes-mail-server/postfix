#!/usr/bin/env sh

function required () {
    eval v="\$$1";

    if [ -z "$v" ]; then
        echo "$1 envvar is not configured, exiting..."
        exit 0;
    else
        [ ! -z "${ENTRYPOINT_DEBUG}" ] && echo "Rewriting required variable '$1' in file '$2'"
        sed -i "s~{{ $1 }}~$v~g" $2
    fi
}

function optional () {
    eval v="\$$1";

    [ ! -z "${ENTRYPOINT_DEBUG}" ] && echo "Rewriting optional variable '$1' in file '$2'"
    sed -i "s~{{ $1 }}~$v~g" $2
}

[ -z "${POSTFIX_TLS_LOGGING_LEVEL}" ] && POSTFIX_TLS_LOGGING_LEVEL=1

for file in $(find /etc/postfix -type f); do
    required DOMAIN ${file}
    required HOSTNAME ${file}
    required RECIPIENT_DELIMITER ${file}
    required POSTFIX_MESSAGE_SIZE_LIMIT ${file}
    required POSTFIX_RELAY_NETS ${file}
    optional POSTFIX_RELAY_HOST ${file}
    required POSTFIX_SUBMISSION_PORT ${file}

    optional POSTFIX_SMTPD_LOGGING_LEVEL ${file}
    required POSTFIX_TLS_LOGGING_LEVEL ${file}

    required DATABASE_HOSTNAME ${file}
    required DATABASE_USERNAME ${file}
    required DATABASE_PASSWORD ${file}
    required DATABASE_NAME ${file}
    required DATABASE_PORT ${file}

    required DOVECOT_HOSTNAME ${file}
    required DOVECOT_LMTP ${file}

    required OPENDKIM_HOSTNAME ${file}
    required OPENDKIM_PORT ${file}

    required RSPAMD_HOSTNAME ${file}
    required RSPAMD_PORT ${file}
done

required HOSTNAME /etc/postsrsd/postsrsd.conf

# The SRS signing secret comes from the optional postsrsd Secret, so addresses signed before a
# restart still verify. Without it a fresh secret is made, which only breaks bounces to mail
# forwarded before the restart.
if [ -s /etc/postsrsd-secret/secret ]; then
    install -m 600 /etc/postsrsd-secret/secret /etc/postsrsd/postsrsd.secret
else
    echo "postsrsd: no postsrsd Secret mounted, using a temporary signing secret"
    (umask 077; head -c 24 /dev/urandom | base64 > /etc/postsrsd/postsrsd.secret)
fi

echo "Running '$@'"
exec $@

