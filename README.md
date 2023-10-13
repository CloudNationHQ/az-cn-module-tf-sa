# Storage Account

This terraform module simplifies the process of creating and managing storage accounts on azure with customizable options and features, offering a flexible and powerful solution for managing azure storage through code.

## Goals

The main objective is to create a more logic data structure, achieved by combining and grouping related resources together in a complex object.

The structure of the module promotes reusability. It's intended to be a repeatable component, simplifying the process of building diverse workloads and platform accelerators consistently.

A primary goal is to utilize keys and values in the object that correspond to the REST API's structure. This enables us to carry out iterations, increasing its practical value as time goes on.

A last key goal is to separate logic from configuration in the module, thereby enhancing its scalability, ease of customization, and manageability.

## Features

- offers support for shares, tables, containers, and queues.
- employs management policies using a variety of rules.
- provides advanced threat protection capabilities.
- utilization of terratest for robust validation.
- facilitates cors to securely control access to assets across different domains.
- enables active directory based authentication for azure file Shares, enhancing file access security.

The below examples shows the usage when consuming the module:

## Usage: simple

```hcl
module "storage" {
  source = "github.com/cloudnationhq/az-cn-module-tf-sa"

  storage = {
    name          = module.naming.storage_account.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
  }
}
```

## Usage: queues

```hcl
module "storage" {
  source = "github.com/cloudnationhq/az-cn-module-tf-sa"

  naming = local.naming

  storage = {
    name          = module.naming.storage_account.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    queue_properties = {
      logging = {
        read              = true
        retention_in_days = 8
      }

      queues = {
        q1 = {
          metadata = {
            environment = "dev"
            owner       = "finance team"
            purpose     = "transaction_processing"
          }
        }
      }
    }
  }
}
```

## Usage: blob containers

```hcl
module "storage" {
  source = "github.com/cloudnationhq/az-cn-module-tf-sa"

  naming = local.naming

  storage = {
    name          = module.naming.storage_account.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    blob_properties = {
      versioning               = true
      last_access_time         = true
      change_feed              = true
      restore_policy           = true
      delete_retention_in_days = 8
      restore_in_days          = 7

      containers = {
        sc1 = {
          access_type = "private"
          metadata = {
            project = "marketing"
            owner   = "marketing team"
          }
        }
      }
    }
  }
}
```

## Usage: shares

```hcl
module "storage" {
  source = "github.com/cloudnationhq/az-cn-module-tf-sa"

  naming = local.naming

  storage = {
    name          = module.naming.storage_account.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    share_properties = {
      smb = {
        versions             = ["SMB3.1.1"]
        authentication_types = ["Kerberos"]
        multichannel_enabled = false
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
```

In scenarios where Azure File Shares require Active Directory-based authentication, employ the following optional configuration:

```hcl
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
}
```

## Usage: management policy

```hcl
module "storage" {
  source = "github.com/cloudnationhq/az-cn-module-tf-sa"

  storage = {
    name              = module.naming.storage_account.name_unique
    location          = module.rg.groups.demo.location
    resourcegroup     = module.rg.groups.demo.name
    threat_protection = true

    blob_properties = {
      last_access_time = true
    }

    mgt_policy = {
      rules = {
        rule1 = {
          filters = {
            filter_specs = {
              prefix_match = ["container1/prefix1"]
              blob_types   = ["blockBlob"]
            }
          }
          actions = {
            base_blob = {
              blob_specs = {
                tier_to_cool_after_days_since_modification_greater_than    = 11
                tier_to_archive_after_days_since_modification_greater_than = 51
                delete_after_days_since_modification_greater_than          = 101
              }
            }
            snapshot = {
              snapshot_specs = {
                change_tier_to_archive_after_days_since_creation = 90
                change_tier_to_cool_after_days_since_creation    = 23
                delete_after_days_since_creation_greater_than    = 31
              }
            }
            version = {
              version_specs = {
                change_tier_to_archive_after_days_since_creation = 9
                change_tier_to_cool_after_days_since_creation    = 90
                delete_after_days_since_creation                 = 3
              }
            }
          }
        },
        rule2 = {
          filters = {
            filter_specs = {
              prefix_match = ["container1/prefix3"]
              blob_types   = ["blockBlob"]
            }
          }
          actions = {
            base_blob = {
              blob_specs = {
                tier_to_cool_after_days_since_last_access_time_greater_than    = 30
                tier_to_archive_after_days_since_last_access_time_greater_than = 90
                delete_after_days_since_last_access_time_greater_than          = 365
                auto_tier_to_hot_from_cool_enabled                             = true
              }
            }
          }
        }
      }
    }
  }
}
```


## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |
| [azurerm_storage_management_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_advanced_threat_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/advanced_threat_protection) | resource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `storage` | describes storage related configuration | object | yes |
| `naming` | contains naming convention	| string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `account` | contains all storage account config |
| `subscriptionId` | contains the id of the current subscription |
| `containers` | contains all containers config |
| `shares` | contains all file shares config |
| `queues` | contains all queues config |
| `tables` | contains all tables config |

## Examples

- [multiple storage accounts](https://github.com/cloudnationhq/az-cn-module-tf-sa/tree/main/examples/multiple/main.tf)
- [storage account using multiple queues](https://github.com/cloudnationhq/az-cn-module-tf-sa/tree/main/examples/queues/main.tf)
- [storage account using multiple containers](https://github.com/cloudnationhq/az-cn-module-tf-sa/tree/main/examples/containers-blob/main.tf)
- [storage account using multiple shares](https://github.com/cloudnationhq/az-cn-module-tf-sa/tree/main/examples/shares/main.tf)
- [management policy with multiple rules ](https://github.com/cloudnationhq/az-cn-module-tf-sa/tree/main/examples/management-policies/main.tf)

## Testing

As a prerequirement, please ensure that both go and terraform are properly installed on your system.

The [Makefile](Makefile) includes two distinct variations of tests. The first one is designed to deploy different usage scenarios of the module. These tests are executed by specifying the TF_PATH environment variable, which determines the different usages located in the example directory.

To execute this test, input the command ```make test TF_PATH=simple```, substituting simple with the specific usage you wish to test.

The second variation is known as a extended test. This one performs additional checks and can be executed without specifying any parameters, using the command ```make test_extended```.

Both are designed to be executed locally and are also integrated into the github workflow.

Each of these tests contributes to the robustness and resilience of the module. They ensure the module performs consistently and accurately under different scenarios and configurations.

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/az-cn-module-tf-sa/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/az-cn-module-tf-sa/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/storage)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/storagerp/storage-accounts)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/1f449b5a17448f05ce1cd914f8ed75a0b568d130/specification/storage)
