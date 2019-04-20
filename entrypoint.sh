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

for file in $(find /etc/postfix -type f); do
    required SERVER_DOMAIN ${file}
    required SERVER_HOSTNAME ${file}
    required MESSAGE_SIZE_LIMIT ${file}
    required RELAY_NETS ${file}
    optional RELAY_HOST ${file}
    required RECIPIENT_DELIMITER ${file}
    optional LOGGING_LEVEL ${file}
    required INTERNAL_SMTPD_PORT ${file}

    required DATABASE_HOSTNAME ${file}
    required DATABASE_USERNAME ${file}
    required DATABASE_PASSWORD ${file}
    required DATABASE_NAME ${file}
    required DATABASE_PORT ${file}

    required LMTP_HOSTNAME ${file}
    required LMTP_PORT ${file}

    required OPENDKIM_HOSTNAME ${file}
    required OPENDKIM_PORT ${file}

    required RSPAMD_HOSTNAME ${file}
    required RSPAMD_PORT ${file}
done

echo "Running '$@'"
exec $@

