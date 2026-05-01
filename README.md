## To run Waydroid, the kernel must support Android-specific IPC and a virtualized network stack. Below are the essential components enabled in your configuration:

### 1. Android IPC (Inter-Process Communication)

CONFIG_ANDROID_BINDER_IPC: The core driver that allows Android processes to communicate. Without this, the Android "Service Manager" cannot start.

CONFIG_ANDROID_BINDERFS: A modern way to mount the binder driver as a filesystem. This provides the /dev/binder, /dev/hwbinder, and /dev/vndbinder nodes required by the container.

CONFIG_PSI (Pressure Stall Information): Critical. Modern Android versions (10+) require PSI to track memory, CPU, and I/O pressure. If this is disabled, the Android Low Memory Killer (LMK) will crash, causing the container to fail during boot.

### 2. Networking & Bridge Support

Waydroid creates a virtual bridge (waydroid0) to provide connectivity to the container.

CONFIG_BRIDGE & CONFIG_BRIDGE_NETFILTER: Enables the creation of virtual Ethernet bridges and allows firewall rules to be applied to traffic passing through them.

CONFIG_VLAN_8021Q: Supports virtual LANs, often used in complex container networking setups.

CONFIG_NET_SCHED: Enables traffic control and packet scheduling, required for managing bandwidth within the container.

### 3. Netfilter & IP Tables (Firewall/NAT)

Waydroid uses iptables to perform Network Address Translation (NAT) so the container can share the host's internet connection.

CONFIG_NETFILTER_XTABLES & CONFIG_NETFILTER_XTABLES_LEGACY: Provides the framework for iptables. Waydroid still relies on the "legacy" interface for its setup scripts.

CONFIG_IP_NF_IPTABLES & CONFIG_IP6_NF_IPTABLES: The base drivers for IPv4 and IPv6 packet filtering.

CONFIG_IP_NF_NAT & CONFIG_IP_NF_TARGET_MASQUERADE: Essential for "Masquerading." This allows the container's private IP (192.168.240.x) to be translated to the host's IP for internet access.

CONFIG_NETFILTER_XT_TARGET_CHECKSUM: Fixes a common Waydroid issue where DHCP packets are rejected by the container because the checksum wasn't calculated correctly by the bridge.
