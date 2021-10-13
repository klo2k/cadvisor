# cAdvisor Docker image for Raspberry Pi OS on ARM

My own Docker image for running cAdvisor on Raspberry Pi OS.

There's no official image [yet](https://github.com/google/cadvisor/issues/1236), so I'm building one for myself.

I might as well share it :-) .

(For x64, use the official image - [gcr.io/cadvisor/cadvisor](https://github.com/google/cadvisor/))




# To run
An example from [official Readme](https://github.com/google/cadvisor#quick-start-running-cadvisor-in-a-docker-container):
```
docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  klo2k/cadvisor:v0.38.8
```




# Building with "docker buildx" locally
Initialise [buildx](https://docs.docker.com/buildx/working-with-buildx/), if you're on a x64 machine:
```
# Enable experimental mode
export DOCKER_CLI_EXPERIMENTAL=enabled

# Enable ARM support
docker run --privileged --rm tonistiigi/binfmt --install all

# Verify you have "linux/arm/v7" and "linux/arm64" platforms available
docker buildx inspect default
```

Build ARM 32-bit (armv7l):
```
docker buildx build --pull \
  --platform "linux/arm/v7" \
  --tag "klo2k/cadvisor" \
  --output=type=docker \
  .
```

Build ARM 64-bit (aarch64) - **UNTESTED**:
```
docker buildx build --pull \
  --platform "linux/arm64" \
  --tag "klo2k/cadvisor" \
  --output=type=docker \
  .
```




# Credits
- *Ondřej Záruba (Budry)*: For his [Dockerfile](https://github.com/Budry/cadvisor-arm/blob/master/Dockerfile)
- *Roland Huß (rhuss)*: For his [Dockerfile](https://github.com/google/cadvisor/issues/1236#issuecomment-578093121)
