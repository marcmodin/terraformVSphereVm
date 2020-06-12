
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}
data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  count         = var.network_cards != null ? length(var.network_cards) : 0
  name          = var.network_cards[count.index]
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

## TODO: below doesn't work since since length(map) filters out duplicate keys
## tags = {
##   "category_name" = "tag1"
##   "category_name" = "tag2"
## }
##  
# data "vsphere_tag_category" "category" {
#   # count = var.tags != null ? length(var.tags) : 0
#   count = length(var.tags)
#   name  = keys(var.tags)[count.index]
# }

data "vsphere_tag_category" "category" {
  name = var.tag_category
}

data "vsphere_tag" "tag" {
  count       = var.tags != null ? length(var.tags) : 0
  name        = var.tags[count.index]
  category_id = data.vsphere_tag_category.category.id
}

resource "vsphere_virtual_machine" "Linux" {
  count = var.is_windows_image != "true" && var.vmnames != null ? length(var.vmnames) : 0
  name  = var.vmnames[count.index]

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  cpu_hot_add_enabled = true
  num_cpus            = var.cpu_number

  memory_hot_add_enabled = true
  memory                 = var.ram_size

  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  firmware  = data.vsphere_virtual_machine.template.firmware
  guest_id  = data.vsphere_virtual_machine.template.guest_id

  folder = var.vmfolder

  # TODO: work on fixing linux customize block
  # wait_for_guest_net_routable = true
  # wait_for_guest_net_timeout = 5
  # wait_for_guest_ip_timeout = 5

  # advanced options: delay booting until vmware have is ready
  boot_delay          = var.boot_delay
  sync_time_with_host = true

  tags = data.vsphere_tag.tag[*].id

  dynamic "network_interface" {
    for_each = var.network_cards
    content {
      network_id   = data.vsphere_network.network[network_interface.key].id
      adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  // Disks defined in the original template
  dynamic "disk" {
    for_each = data.vsphere_virtual_machine.template.disks
    iterator = template_disks
    content {
      label            = "disk${template_disks.key}"
      size             = var.disk_size != null ? var.disk_size : data.vsphere_virtual_machine.template.disks[template_disks.key].size
      unit_number      = template_disks.key
      thin_provisioned = data.vsphere_virtual_machine.template.disks[template_disks.key].thin_provisioned
      eagerly_scrub    = data.vsphere_virtual_machine.template.disks[template_disks.key].eagerly_scrub
    }
  }

}

resource "vsphere_virtual_machine" "Windows" {
  count = var.is_windows_image == "true" && var.vmnames != null ? length(var.vmnames) : 0
  name  = var.vmnames[count.index]

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.cpu_number
  memory   = var.ram_size

  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  firmware  = data.vsphere_virtual_machine.template.firmware
  guest_id  = data.vsphere_virtual_machine.template.guest_id

  folder = var.vmfolder

  # delay booting until vmware have is ready
  boot_delay          = var.boot_delay
  sync_time_with_host = true

  tags = data.vsphere_tag.tag[*].id

  dynamic "network_interface" {
    for_each = var.network_cards
    content {
      network_id   = data.vsphere_network.network[network_interface.key].id
      adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name         = var.vmnames[count.index]
        time_zone             = var.time_zone
        admin_password        = var.default_password
        join_domain           = var.domain_name
        domain_admin_user     = var.domain_username
        domain_admin_password = var.domain_password

        # run_once_command_list = var.run_once
      }
      # add empty network_interface list for some dhcp action
      dynamic "network_interface" {
        for_each = var.network_cards
        content {}
      }

    }
  }
  // Disks defined in the original template
  dynamic "disk" {
    for_each = data.vsphere_virtual_machine.template.disks
    iterator = template_disks
    content {
      label            = "disk${template_disks.key}"
      size             = data.vsphere_virtual_machine.template.disks[template_disks.key].size
      unit_number      = template_disks.key
      thin_provisioned = data.vsphere_virtual_machine.template.disks[template_disks.key].thin_provisioned
      eagerly_scrub    = data.vsphere_virtual_machine.template.disks[template_disks.key].eagerly_scrub
    }
  }

}
