package main

import (
	"context"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage"
	"github.com/cloudnationhq/az-cn-module-tf-sa/shared"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestStorage(t *testing.T) {
	t.Run("verifyStorage", func(t *testing.T) {
		t.Parallel()

		tfOptions := shared.GetTerraformOptions("../examples/complete")
		defer shared.Cleanup(t, tfOptions)
		terraform.InitAndApply(t, tfOptions)

		storage := terraform.OutputMap(t, tfOptions, "storage")
		saName, ok := storage["name"]
		require.True(t, ok, "storage name not found in terraform output")

		resourceGroupName, ok := storage["resource_group_name"]
		require.True(t, ok, "Resource group name not found in terraform output")

		subscriptionId := terraform.Output(t, tfOptions, "subscriptionId")
		require.NotEmpty(t, subscriptionId, "Subscription ID not found in terraform output")

		cred, err := azidentity.NewDefaultAzureCredential(nil)
		if err != nil {
			t.Fatalf("Failed to get credentials: %v", err)
		}

		client, err := armstorage.NewAccountsClient(subscriptionId, cred, nil)
		if err != nil {
			t.Fatalf("Failed to get storage client: %v", err)
		}

		resp, err := client.GetProperties(context.Background(), resourceGroupName, saName, nil)
		if err != nil {
			t.Fatalf("Failed to get storage account: %v", err)
		}

		t.Run("verifyStorage", func(t *testing.T) {
			verifiyStorage(t, saName, &resp.Account)
		})
	})
}

func verifiyStorage(t *testing.T, saName string, storage *armstorage.Account) {
	t.Helper()

	require.Equal(
		t,
		saName,
		*storage.Name,
		"Storage name does not match expected value",
	)

	require.Equal(
		t,
		"Succeeded",
		string(*storage.Properties.ProvisioningState),
		"Storage provisioning is not Succeeded",
	)

	require.True(
		t,
		strings.HasPrefix(saName, "st"),
		"Storage name does not begin with the right abbreviation",
	)
}
