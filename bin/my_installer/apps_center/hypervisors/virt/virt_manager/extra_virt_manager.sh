#!/bin/sh
. "$__distro_path_lib"
. "${__distro_path_root}/lib/common/common"
. "${__distro_path_root}/lib/common/my_installer_and_DB_dir"

say "Type: quickemu_installer to install quickemu for quick deploy any VM."
create_never_remove_bin "${_APPS_LIBDIR}/hypervisors/virt/virt_manager/quickemu_installer"
say "Type: QuickPassthrough_installer to install QuickPassthrough which enable GPU passthrough at OS level not at virt-manager level."
create_never_remove_bin "${_APPS_LIBDIR}/hypervisors/virt/virt_manager/QuickPassthrough_installer"
say "Type: windows_vm_installer to auto deploy windows vm."
create_never_remove_bin "${_APPS_LIBDIR}/hypervisors/virt/virt_manager/windows_vm_installer"
say "Type: android_vm_builder to auto deploy android vm."
create_never_remove_bin "${_APPS_LIBDIR}/hypervisors/virt/virt_manager/android_vm_builder"
create_never_remove_bin "${_APPS_LIBDIR}/hypervisors/virt/virtual_machine"
