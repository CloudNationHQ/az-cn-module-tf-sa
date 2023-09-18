output "account" {
  value = azurerm_storage_account.sa
}

output "subscriptionId" {
  value = data.azurerm_subscription.current.subscription_id
}

output "containers" {
  value = azurerm_storage_container.sc
}

output "shares" {
  value = azurerm_storage_share.sh
}

output "queues" {
  value = azurerm_storage_queue.sq
}

output "tables" {
  value = azurerm_storage_table.st
}
