output "storage" {
  value     = module.storage.sa
  sensitive = true
}

output "subscriptionId" {
  value = module.storage.subscriptionId
}
