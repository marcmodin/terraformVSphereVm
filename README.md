# VSphere Virtual Machine Terraform Module

[Example](#example)

This repo contains a Terraform module to provison VSphere VM's cloned from a template.

### Who maintains this Module?

This module was created for a specific use and is not actively maintained as such. It may not work as expected in your specific environment. But feel free to clone this repo to make it work for you.

## Explanations

This module creates a virtual machine from a template clone on vSphere. It can either create a Linux or a Windows machine. When provisioning Windows you have the option to join the domain directly with customize options. If you do, be aware that the process may take some time and several automatical reboots will be performed. Below are a few things to keep in mind. Customize options are not available on Linux for this module yet.

- Setting variable `is_windows_image: true` selects the Windows resource within the module, it's default value is `false` for Linux

- Set your vsphere credentials on top of the `main.tf` file or in `*.tfvars`. see example below!

- Optionally include sensitive data in `creds.tfvars.json` instead. This file should not be submitted to git. Call command with the file `terraform plan/apply/destroy -var-file="creds.tfvars.json" ./main.tf`

- Including the `creds.tfvars.json` as json is especially useful if Terraform is used in conjuntion with other automation tools such as ansible, since they can share the same credentials from this file. JSON file example below. Then declare sensitive variables at the top of the `main.tf` file or in `*.auto.tfvars`.

  ```json
  {
    "vsphere_server": "",
    "vsphere_username": "",
    "vsphere_password": ""
  }
  ```

- On Windows. Not setting domain will default to workgroup and the administrator password is set from the Vsphere template itself.

- Destroying an instance can be tricky if you have many instances, and only want selected to be destroyed. Then you have to use `terraform taint` to preserve the tfstate index. Otherwise `terraform destroy` often takes the last one in the index.

## Required Inputs

**Required Provider Connection Inputs**

---

- `vsphere_server` | string
  Description: FQDN or IP to vsphere server, passed in to provider. Passed in via \*.tfvars or set in the `main.tf`.

- `vsphere_username` | string
  Description: Vsphere admin username, passed in to provider. Passed in via \*.tfvars or set in the `main.tf`.

- `vsphere_password` | string
  Description: Vsphere admin userpassword, passed in to provider. Passed in via \*.tfvars or set in the `main.tf`.

**Required Inputs**

---

- `vmnames` | list(string)  
  Description: Name of VM passed in as a list. Length of list also acts as instance count.

- `network_cards` | list(string)  
  Description: Network Interface ID passed in as list.

- `template` | string
  Description: Name of the Vsphere template to use.

- `datacenter` | string
  Description: Name of the datacenter you want to deploy the VM to.

- `cluster` | string
  Description: Datastore cluster to deploy the VM.

- `datastore` | string
  Description: Datastore to deploy the VM.

## Default Inputs

Default inputs as stated in `varibles.tf` under `# Defaults`

---

**Windows Customize Inputs**
_Null is where terraform ignores the field and is not included in the resource it provisions. Most Optional inputs are null per default._

- `is_windows_image` | bool
  Description: set to true for windows. default false for linux.

- `domain_name` | string  
  Description: The default domain address. Can be passed in via auto.tfvars or set in the `main.tf`.

- `default_password` | string  
  Description: The administrator password for this virtual machine.(Required) when using join_domain option. Can be passed in via auto.tfvars or set in the `main.tf`.

- `domain_username` | string  
  Description: The default domain admin username. Can be passed in via auto.tfvars or set in the `main.tf`.

- `domain_password` | string  
  Description: The default domain admin password. Can be passed in via auto.tfvars or set in the `main.tf`.

## Outputs

None

---

## Example

```

variable "vsphere_server" {type = string}
variable "vsphere_username" {type = string}
variable "vsphere_password" {type = string}

variable "domain_name" {type = string}
variable "default_user_password" {type = string}
variable "domain_admin_password" {type = string}
variable "domain_admin_username" {type = string}

provider "vsphere" {
  user                  = var.vsphere_username
  password              = var.vsphere_password
  vsphere_server        = var.vsphere_server
  allow_unverified_ssl  = true
  version               = "~> 1.16.0"
}

# Windows VM
module "vsphere-windows" {
  source            = ""

  is_windows_image  = "true"
  template          = "(your vsphere windows template)"
  vmfolder          = "(your vsphere folder)"

  vmnames           = ["vm-name"]

  # if vm is to be joined to domain
  domain            = var.domain_name
  domain_username   = var.domain_admin_username
  domain_password   = var.domain_admin_password


  cpu_number        = 4
  ram_size          = 4096

  network_cards     = ["(vsphere distributed switch port group number)"]

  tag_category = "(your vsphere category name)"
  tags = ["(your vsphere tag)"]

}

# Linux VM
module "vsphere-linux" {
  source            = ""

  template          = "(your vsphere linux template)"
  vmfolder          = "(your vsphere folder)"

  vmnames           = ["vm-name"]

  cpu_number        = 4
  ram_size          = 4096

  network_cards     = ["(vsphere distributed switch port group number)"]

  tag_category = "(your vsphere category name)"
  tags = ["(your vsphere tag)"]

}

```

---

### Todo:

- Workout how to add tags with a map variable. The VSphere provider need a tag category and terraform doesn't allow duplicated keys, meaning that the following wont:\_

```
tags = {
"category" = "tag1"
"category" = "tag2"
}
```

- Add logic to join domain or not, preferrable with a contiditonal block inclusion in the resource declaration.
- Add ability to provision with multiple disks, networkcards
- Get customize options to work on Linux
