provider "vsphere" {
  user = var.user
  password = var.pass
  vsphere_server = var.server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "resource_pool" {
  name = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_disk" "virtual_disk" {
  size               = 40
  type               = "thin"
  vmdk_path          = "Solaris.vmdk"
  datacenter         = data.vsphere_datacenter.dc.name
  datastore          = data.vsphere_datastore.datastore.name
}

resource "vsphere_virtual_machine" "solaris" {
  name = "Solaris"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id = data.vsphere_datastore.datastore.id
  num_cpus = var.cpu
  memory = var.memory
  guest_id = "solaris11_64Guest"
  scsi_type = "lsilogic"

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = "e1000e"
  }

  disk {
    label = var.disk_label
    attach = true
    path = "${vsphere_virtual_disk.virtual_disk.vmdk_path}"
    datastore_id = data.vsphere_datastore.datastore.id
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path = "Solaris/sol-11_4-text-x86.iso"
  }
  
}