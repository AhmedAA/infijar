 ﷽

# Infijar - Offensive Security container image

This project contains a containerfile to build a custom container that is ready
to go for pentesting/training. It is an opinionated setup with the tools that I
primarily use.

The magic is in the Ansible collection though, and not really here.

See the collection here: <https://github.com/AhmedAA/infijar-ansible>

## Building container

Podman:

```shell
sudo podman build --build-arg "NETSEC=true" --build-arg "APPSEC=true" --build-arg "BURP_COMMUNITY=true" --build-arg "BURP_PRO=false" -t infijar -f Containerfile .
```

Docker (poor you):

```shell
docker build --build-arg "NETSEC=true" --build-arg "APPSEC=true" --build-arg "BURP_COMMUNITY=true" --build-arg "BURP_PRO=false" -t infijar -f Containerfile .
```

## Run with VNC and VPN capabilities

```shell
sudo podman run -it \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --device /dev/net/tun:/dev/net/tun \
  -v /path/to/your/config.ovpn:/root/my-vpn.ovpn:z \
  -e VNC_PASSWORD=your-secret-password \
  infijar:latest \
```

From within the container, run `start-desktop` and connect to VNC.

## Run with X forwarding

If you do not want to run a full desktop, but still want GUI apps.

```shell
xhost +local:root

sudo podman run -it --rm \
  --net=host \
  --cap-add=NET_RAW \
  --env DISPLAY=$DISPLAY \
  --volume /tmp/.X11-unix:/tmp/.X11-unix \
  --security-opt label=disable \
  infijar:latest
```

Run when developing:

```shell
sudo podman run -d --name infijar-dev -v <PATH/TO/ANSIBLE/COLLECTION/ROOT>:/root/.ansible/collections/ansible_collections/offensive_security/tools:z -v <PATH/TO/CONTAINER/BUILD/FOLDER>:/builder:z --network=host infijar-dev

sudo podman exec infijar-dev ansible-playbook /builder/playbook.yml -e "container=true" -e "desktop=true" -e "build_appsec=true" -e "build_desktop=true"
```