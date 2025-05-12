FROM openjdk:8-jre-alpine

ENV	SERVICE_USER=myuser \
	SERVICE_UID=10001 \
	SERVICE_GROUP=mygroup \
	SERVICE_GID=10001

RUN	addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} && \
	adduser -g "${SERVICE_NAME} user" -D -H -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER} && \
        apk add --update libcap

# Musl does not take into account both LD_LIBRARY_PATH and RPATH when
# launching a process with elevated capabilities.
# In this case we are giving java `net_bind_service` so we need to provide
# a path to the libraries.
COPY ld-x86_64.path /etc/ld-musl-x86_64.path
COPY ld-aarch64.path /etc/ld-musl-aarch64.path

RUN setcap 'cap_net_bind_service=+ep' $(readlink -f $(which java))
