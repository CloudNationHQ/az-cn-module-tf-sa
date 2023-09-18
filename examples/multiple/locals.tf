locals {
  storage = {
    sa1 = {
      name          = join("", [module.naming.storage_account.name_unique, "001"])
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name

      share_properties = {
        smb = {
          versions             = ["SMB3.1.1"]
          authentication_types = ["Kerberos"]
          multichannel_enabled = false
        }

        shares = {
          operations = {
            quota = 50
            metadata = {
              environment = "dev"
              owner       = "operations team"
            }
          }
        }
      }
    },
    sa2 = {
      name          = join("", [module.naming.storage_account.name_unique, "002"])
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name

      share_properties = {
        smb = {
          versions             = ["SMB3.1.1"]
          authentication_types = ["Kerberos"]
          multichannel_enabled = false
        }

        shares = {
          finance = {
            quota = 50
            metadata = {
              environment = "prd"
              owner       = "finance team"
            }
          }
        }
      }
    }
  }
}

locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["storage_container", "storage_share", "storage_queue", "storage_table"]
}
