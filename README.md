# docker-dhcp

Minimal DHCP client for shared container network namespaces.

Image size <1MiB, Memory usage <512KiB.

## Usecases

In the case of running multiple containers under one host, that need separate IPs, Docker does not provide
a way to automagically manage DHCP for `macvlan` networks.

This is particularly useful for automatically creating DNS records for the container by its hostname
(via something like [Technitium](https://technitium.com/dns/)), much like you would see with each service being
isolated to a separate LXC or VM.

This bridges that gap (in a very ugly way), by sharing a network namespace with the target container, and 
managing IPAM for that target container without having to edit, or override, or add additional
permissions (like promiscuous mode) to the original target container.

## Usage

There is two primary ways to share a network namespace:

1. Attach the target container to the DHCP container's network namespace.
   The target container must have `ifconfig` or `iproute2` installed in its image,
   in order for the *necessary* healthcheck to function.
   This method is primarily useful when there is more than one target container that 
   needs to share the same dynamic IP; in the same way that Gluetun can provide a
   TUN interface to multiple containers.
2. Attach the DHCP container to the target container's network namespace.

See [this](./docker-compose.example1.yml) Docker compose setup for the 1st option.
See [this](./docker-compose.example2.yml) Docker compose setup for the 2nd option.

## Healthcheck

Due to an oversight in the Docker engine, shared network namespace interfaces are not reattached after
the host container is restarted/recreated. As such, the only way to ensure that "child" containers relying
on that interface, also get recreated, is a healthcheck:

```yml
healthcheck:
  # Ensure that network interface is still attached
  test: ["CMD-SHELL", "ifconfig | grep -q eth || kill 1"]
  interval: 1m
  timeout: 3s
  retries: 1
  start_period: 30s
```

As such, if using the aforementioned method 1, the target container must either have `ifconfig` installed,
or `iproute2`, in which case `ifconfig` should be changed to `ip addr` in the healthcheck.
