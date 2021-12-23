packer {
  required_version = ">= 1.7.0"
}

//////////////////////////////////////////////
//
//               Authentication
//
//////////////////////////////////////////////

variable "vsphere-password" {
  type    = string
  default = "PasswordIsSetInSecretFile"
  sensitive   = true
}

variable "vsphere-server" {
  type    = string
  default = "vsphere-01"
}

variable "vsphere-user" {
  type    = string
  default = "administrator@vsphere.local"
  sensitive   = true
}


//////////////////////////////////////////////
// 
//               vSphere Settings
//
//////////////////////////////////////////////

variable "vsphere-cluster" {
  type    = string
  default = "Cluster"
}

variable "vsphere-datacenter" {
  type    = string
  default = "Home"
}

variable "vsphere-datastore" {
  type    = string
  default = "Datastore"
}

variable "vsphere-folder" {
  type = string
  description = "Folder to place VM in vSphere"
  default = "Templates"
}

variable "vsphere-resource-pool"{
  type = string
  description = "Resource Pool to create VM in"
  default = "Low"
}

variable "vsphere-content-libary"{
  type = string
  description = "Content libary to store the template in"
  default = "VM"
}

variable "git-branch"{
  type = string
  description = "branch name"
  default = "development"
}

variable "os_family"{
  type = string
  description = "Windows or Linux"
  default = "Linux"  
}
//////////////////////////////////////////////
//
//               Vm Settings
//
//////////////////////////////////////////////

variable "vm-cpu-num" {
  type    = string
  default = "1"
}

variable "vm-disk-size" {
  type    = string
  default = "25600"
}

variable "vm-mem-size" {
  type    = string
  default = "1024"
}

variable "vm-name" {
  type    = string
  default = "CentOS7"
}

variable "iso_url" {
  type    = string
  default = "[Datastore] ISO-Linux/CentOS-7-x86_64-DVD-1810.iso"
}

variable "vsphere-network" {
  type    = string
  default = "VM Network"
}

//////////////////////////////////////////////
//
//               Builder Settings
//
//////////////////////////////////////////////

source "vsphere-iso" "centOS7" {
  CPUs                  = "${var.vm-cpu-num}"
  CPU_hot_plug          = true
  RAM                   = "${var.vm-mem-size}"
  RAM_hot_plug          = true
  RAM_reserve_all       = false
  boot_command          = ["<esc><wait>", "linux ks=hd:fd0:/ks.cfg<enter>"]
  boot_order            = "disk,cdrom,floppy"
  boot_wait             = "10s"
  insecure_connection   = "true"
  cluster               = "${var.vsphere-cluster}"
  datacenter            = "${var.vsphere-datacenter}"
  datastore             = "${var.vsphere-datastore}"
  resource_pool         = "${var.vsphere-resource-pool}"
  folder                = "${var.vsphere-folder}/${var.git-branch}/${var.os_family}"
  usb_controller        = ["usb"]
  disk_controller_type  = ["pvscsi","lsilogic"]
  cdrom_type            = "ide"
  firmware              = "bios"
  storage{
    disk_size             = "${var.vm-disk-size}"
    disk_thin_provisioned = true
    disk_controller_index = 0
  }
  floppy_files          = ["ks.cfg"]
  vm_version            = "19"
  guest_os_type         = "centos7_64Guest"
  iso_paths             = ["${var.iso_url}"]
  network_adapters{
    network             = "${var.vsphere-network}"
    network_card        = "vmxnet3"
  }
  tools_upgrade_policy  = true
  ip_wait_timeout       = "1h"
  notes                 = "Packer generated CentOS7 template on ${timestamp()}"
  password              = "${var.vsphere-password}"
  ssh_password          = "server"
  ssh_username          = "root"
  ssh_timeout           = "30m"
  username              = "${var.vsphere-user}"
  vcenter_server        = "${var.vsphere-server}"
  vm_name               = lower(format("%s_pkr", var.vm-name ) )
  
  convert_to_template   = true
  content_library_destination {
    library             = "${var.vsphere-content-libary}"
    ovf                 = true
    destroy             = false
  }
}



build {
  sources = ["source.vsphere-iso.centOS7"] 

  provisioner "shell" {
  #commands to run before the vm is converted to a template
    inline = [
      "sudo yum install perl -y",
      "vmware-toolbox-cmd config set deployPkg enable-custom-scripts true",
      "sudo yum -y update && yum -y upgrade"
    ]
  }
}
