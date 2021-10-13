# Build cAdvisor image using mult-stage build

# Build cAdvisor
# Based on
# - https://github.com/google/cadvisor/blob/master/docs/development/build.md
# - https://github.com/Budry/cadvisor-arm/blob/master/Dockerfile
# - https://github.com/google/cadvisor/issues/1236#issuecomment-578093121
FROM golang:1.14 as builder

RUN apt update && \
    apt install --yes git && \
    apt clean

# Shallow clone cAdvisor repo (faster)
RUN git clone --depth 1 --branch "v0.38.8" https://github.com/google/cadvisor.git /go/src/github.com/google/cadvisor

# Build cAdvisor
WORKDIR /go/src/github.com/google/cadvisor
RUN make build




# Runtime image
# Based on official Dockerfile with unnecessary / broken stuff removed - e.g. zfs, libpfm.so, libipmctl.so
# https://github.com/google/cadvisor/blob/master/deploy/Dockerfile
FROM alpine:3.12

LABEL org.opencontainers.image.revision="-"
LABEL org.opencontainers.image.source="https://github.com/klo2k/cadvisor"

RUN apk --no-cache add libc6-compat device-mapper findutils ndctl && \
    apk --no-cache add thin-provisioning-tools --repository http://dl-3.alpinelinux.org/alpine/edge/main/ && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm -rf /var/cache/apk/*

# Copy cAdvisor binary from builder
COPY --from=builder /go/src/github.com/google/cadvisor/cadvisor /usr/bin/cadvisor

EXPOSE 8080

ENV CADVISOR_HEALTHCHECK_URL=http://localhost:8080/healthz

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider $CADVISOR_HEALTHCHECK_URL || exit 1

ENTRYPOINT ["/usr/bin/cadvisor", "-logtostderr"]
