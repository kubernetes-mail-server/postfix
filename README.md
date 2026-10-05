# postfix
The postfix SMTP/SMTPD server used to send and receive emails from the outside world

## Important
You must install the database component beforehand because this relies on the database to check for user accounts  

## Sender Rewriting Scheme

Mail that an alias forwards to another provider (Gmail, say) keeps its original envelope sender,
so the receiving provider checks that sender's SPF against this server and fails it. postsrsd runs
next to postfix and rewrites such senders to `SRS0=...@$HOSTNAME`, whose SPF record names this
server; bounces to those addresses are rewritten back to the original sender. Senders in the hosted
domains are never rewritten.

The signing secret lives in the `postsrsd` Secret, so SRS addresses stay valid across restarts:

    kubectl -n mail-server create secret generic postsrsd --from-literal=secret="$(openssl rand -base64 32)"

Without it the pod makes a temporary secret at every start, which only breaks bounces to mail
forwarded before the restart.
