 ﷽

# Infijar - Offensive Security container image

This project contains a containerfile to build a custom container that is ready
to go for pentesting/training. It is an opinionated setup with the tools that I
primarily use.

The magic is in the Ansible collection though, and not really here.

See the collection here: <https://github.com/AhmedAA/infijar-ansible>

There is a ready to go image here: `sudo podman pull ghcr.io/ahmedaa/infijar:latest`

## Building container

Podman:

```shell
sudo podman build --build-arg "NETSEC=true" --build-arg "APPSEC=true" --build-arg "BURP_COMMUNITY=true" --build-arg "BURP_PRO=false" -t infijar -f Containerfile .
```

Docker (poor you):

```shell
docker build --build-arg "NETSEC=true" --build-arg "APPSEC=true" --build-arg "BURP_COMMUNITY=true" --build-arg "BURP_PRO=false" -t infijar -f Containerfile .
```

## Running containers

**First of all, this is not a VM. You do not get the same level of isolation and
other benefits that a VM provides, if you need that, then please use a VM.**

You will the need following capabilities added to the container, depending on what you are using it for, you can pick and choose when starting it.

- NET_ADMIN - Allows you to set up a VPN tunnel, and generally modify network interfaces.
- NET_RAW - Allows you to perform raw packet socket creation, which is needed by
  for example nmap and responder.
- NET_BROADCAST - Allows you to broadcast network requests.
- SYS_PTRACE - Needed if you use debuggers, such as gdb.
- SYS_ADMIN - Allows for mounting filesystems, managing namespaces, and sysadmin
  tasks.
- SYS_RAWIO - Allows to access raw IO ports (i.e., access to hardware).

I recommend you the capabilities you need to the specific container you start.
If you do not know what you might need, then feel free to add them all, but just
know that it is typically not good practice.

## Run with VNC and VPN capabilities

```shell
sudo podman run -it \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --cap-add=SYS_PTRACE \
  --cap-add=SYS_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -v /path/to/your/config.ovpn:/root/my-vpn.ovpn:z \
  -e VNC_PASSWORD=your-secret-password \
  ghcr.io/ahmedaa/infijar

start-desktop
```

From within the container, run `start-desktop` and connect to VNC.

If you want to run it **without** the `--net=host` flag, then you can start a
noVNC instance, that you can access through your browser:

```shell
sudo podman run -it \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --cap-add=SYS_PTRACE \
  --cap-add=SYS_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -v /path/to/your/config.ovpn:/root/my-vpn.ovpn:z \
  -e VNC_PASSWORD=your-secret-password \
  -e VNC_PROTO=http \
  -e VNC_PORT=6901 \
  -e VNC_BIND_HOST=0.0.0.0 \
  -p 6901:6901 \
  ghcr.io/ahmedaa/infijar

start-desktop
```

## Run with X forwarding

If you do not want to run a full desktop, but still want GUI apps.

```shell
xhost +local:root

sudo podman run -it --rm \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --cap-add=SYS_PTRACE \
  --cap-add=SYS_ADMIN \
  --env DISPLAY=$DISPLAY \
  --volume /tmp/.X11-unix:/tmp/.X11-unix \
  --security-opt label=disable \
  infijar:latest
```

## Run when developing

```shell
sudo podman run -d --name infijar-dev -v <PATH/TO/ANSIBLE/COLLECTION/ROOT>:/root/.ansible/collections/ansible_collections/offensive_security/tools:z -v <PATH/TO/CONTAINER/BUILD/FOLDER>:/builder:z --network=host infijar-dev

sudo podman exec infijar-dev ansible-playbook /builder/playbook.yml -e "container=true" -e "desktop=true" -e "build_appsec=true" -e "build_desktop=true"
```

## How I run it

**Without desktop:**

```shell
xhost +local:root

sudo podman run -it --name infijar-htb \
   --hostname infijar \
   --cap-add=NET_RAW \
   --cap-add=NET_ADMIN \
   --cap-add=SYS_PTRACE \
   --cap-add=SYS_ADMIN \
   --device /dev/net/tun:/dev/net/tun \
   -e DISPLAY=$DISPLAY \
   -v /tmp/.X11-unix:/tmp/.X11-unix \
   -v $(pwd):/workspace \
   --workdir /workspace \
   --security-opt label=disable \
   ghcr.io/ahmedaa/infijar
```

**With desktop:**

```shell
sudo podman run -it --name infijar-htb \
   --network host \
   --cap-add=NET_RAW \
   --cap-add=NET_ADMIN \
   --cap-add=SYS_PTRACE \
   --cap-add=SYS_ADMIN \
   --device /dev/net/tun:/dev/net/tun \
   -e DISPLAY=$DISPLAY \
   -v /tmp/.X11-unix:/tmp/.X11-unix \
   -v $(pwd):/workspace \
   --workdir /workspace \
   --security-opt label=disable \
   ghcr.io/ahmedaa/infijar

start-desktop
```