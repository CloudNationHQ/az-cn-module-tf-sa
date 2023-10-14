module "naming" {
  source = "github.com/cloudnationhq/az-cn-module-tf-naming"

  suffix = ["demo", "dev"]
}

module "rg" {
  source = "github.com/cloudnationhq/az-cn-module-tf-rg"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "storage" {
  source = "../../"

  naming = local.naming

  storage = {
    name          = module.naming.storage_account.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    share_properties = {
      authentication = {
        type = "AD"
        active_directory = {
          domain_name         = "corp.acmeinc.net"
          domain_guid         = "d10a8b2e-0fc1-4d5c-b456-abcdef785612"
          forest_name         = "acme-forest.local"
          domain_sid          = "S-1-5-21-0123487654-0123476543-0123456543-0123"
          storage_sid         = "S-1-5-21-3623811015-3361044348-30300820"
          netbios_domain_name = "ACMECORP"
        }
      }

      shares = {
        fs1 = {
          quota = 50
          metadata = {
            environment = "dev"
            owner       = "finance team"
          }
        }
      }
    }
  }
}
