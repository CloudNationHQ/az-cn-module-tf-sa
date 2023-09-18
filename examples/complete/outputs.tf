output "storage" {
  value     = module.storage.account
  sensitive = true
}

output "subscriptionId" {
  value = module.storage.subscriptionId
}
