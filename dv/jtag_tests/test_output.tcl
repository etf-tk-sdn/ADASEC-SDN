# SPDX-FileCopyrightText: 2026 Amina Tankovic
# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

set masters [get_service_paths master]
set master_path [lsearch -inline -glob $masters "*altera_jtag_avalon_master_inst.master"]

puts $master_path
open_service master $master_path
master_write_32 $master_path 0x00000000 0x00000005
close_service master $master_path
