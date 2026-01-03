#!/bin/sh
# need superuser : called by my-installer		
if [ ! -e "/dev/kvm" ]; then
	say "${RED}KVM is not available. Make sure you have CPU virtualization support enabled in your BIOS/UEFI settings. Please refer https://wiki.archlinux.org/title/KVM for more information.${RC}"
fi

if [ -f /etc/libvirt/virtqemud ];then
	for drv in qemu interface network nodedev nwfilter secret storage; do
		service_manager enable virt${drv}d.service
		for suffix in "" -ro -admin; do
			service_manager enable "virt${drv}d${suffix}.socket"
		done
	done
else
	service_manager enable virtlogd
	service_manager enable libvirtd.socket
	service_manager enable libvirtd.service
	service_manager restart libvirtd.service
fi
		
my-superuser usermod -aG libvirt,libvirt-qemu,kvm,input,disk $USER

test_qemu="$(my-superuser virt-host-validate qemu | grep ': WARN')"
if [ "$test_qemu" = "amd" ] && [ -n "$(echo "$test_qemu" | grep "QEMU: Checking for secure guest support")" ];then
	say "this is a bug visit this link https://bugzilla.redhat.com/show_bug.cgi?id=1850351#c5 and https://libvirt.org/kbase/launch_security_sev.html links to resolve this issue."
	sleep 3
	exit 1
fi
		
if [ -n "$(echo "$test_qemu" | grep 'QEMU: Checking for device assignment IOMMU support')" ];then
	say "failed IOMMU not enable"
	sleep 3
	exit 1
fi

if [ -n "$(echo "$test_qemu" | grep 'QEMU: Checking for device assignment IOMMU support' | grep -v "QEMU: Checking for secure guest support")" ];then
	echo "there are some warrning need to be fixed"
	echo "run this command to see them"
	echo "my-superuser virt-host-validate qemu"
	my-superuser virt-host-validate qemu
	sleep 3
	exit 1
fi

interface_name="$(my-superuser nmcli device status | awk '{print $1}' | head -2 | tail -1 )"
my-superuser virsh net-start default
my-superuser virsh net-autostart default
my-superuser nmcli connection add type bridge con-name bridge0 ifname bridge0
my-superuser nmcli connection add type ethernet slave-type bridge \
	con-name 'Bridge connection 1' ifname $interface_name master bridge0
my-superuser nmcli connection up bridge0
my-superuser nmcli connection modify bridge0 connection.autoconnect-slaves 1
my-superuser nmcli connection up bridge0
my-superuser tee /tmp/$USER/nwbridge.xml <<- 'EOF' > /dev/null
<network>
	<name>nwbridge</name>
	<forward mode='bridge'/>
	<bridge name='bridge0'/>
</network>
EOF
cd /tmp/$USER || continue
my-superuser virsh net-define nwbridge.xml
my-superuser virsh net-start nwbridge
my-superuser virsh net-autostart nwbridge
rm -rf nwbridge.xml

"${_APPS_LIBDIR}/hypervisors/virt/virt_manager"/extra_virt_manager.sh

say
say "${app_name} has been installed successfully."
say
