# Required
variable "vmnames" {
  description = "The name of the virtual machine used to deploy the vms"
  type        = list(string)
}

variable "network_cards" {
  description = "The distributed switch port group number"
  type        = list(string)
}

variable "template" {
  description = "Name of the template available in the vSphere"
}

variable "datacenter" {
  description = "Name of the datacenter you want to deploy the VM to"
}

variable "cluster" {
  description = "Datastore cluster to deploy the VM."
}

variable "datastore" {
  description = "Datastore to deploy the VM."
}

# Defaults

variable "vmfolder" {
  description = "The path to the folder to put this virtual machine in, relative to the datacenter that the resource pool is in."
  default     = null
}

variable "tag_category" {
  description = "The names of any tags to attach to this resource. They should already exist"
  default     = null
}

# tags with type map would be ideal but doesnt work since length(map) filter out any duplicate keys
variable "tags" {
  description = "The names of any tags to attach to this resource. They should already exist"
  type        = list(string)
  default     = null
}

variable "time_zone" {
  description = "The setting for timezone. Defaults to W.Europe Standard Time"
  default     = "110"
}

variable "cpu_number" {
  description = "number of CPU (core per CPU) for the VM. Default is 2 cores. (cpu_hot_add_enabled is set true)"
  # set default here to avoid issues
  default = 2
}

variable "ram_size" {
  description = "VM RAM size in MB.  Default value is 4 GB. (memory_hot_add_enabled is set true)"
  # set default to avoid issues
  default = 4096
}

variable "disk_size" {
  description = "The size of the disk, in GB. Default value set to VSphere Template disk size. (expand the disk in guest manually if set)"
  default     = null
}

variable "boot_delay" {
  description = "Delay boot until vmware is ready. In milliseconds"
  default     = 20000
}

# Windows Customize Variables

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  default     = false
}

variable "domain_name" {
  description = "The default domain address"
  default     = null
}

variable "workgroup" {
  description = "The default workgroup name if any"
  default     = null
}

variable "default_password" {
  description = "The administrator password for this virtual machine. Passed in via auto.tfvars or set in the main.tf"
  default     = null
}

variable "domain_username" {
  description = "The default domain admin password. Required if you are setting join_domain. Passed in via auto.tfvars or set in the main.tf"
  default     = null
}

variable "domain_password" {
  description = "The default domain admin password. Required if you are setting join_domain. Passed in via auto.tfvars or set in the main.tf"
  default     = null
}


# Windows Customization Variables Customization Variables

# TODO: work on conditional to join domain or not
# variable "join_windows_domain" {
#   description = "Boolean flag to notify if windows should join domain."
#   default     = false
# }

# TODO: not working, enabling run-once commands
# variable "run_once" {
#   description = "List of Commands to run during first logon (Automatic login set to 1)"
#   type        = list(string)
#   default     = null
# }
