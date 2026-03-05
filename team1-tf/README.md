# team1-tf
Team 1 Infrastructure as Code — Terraform configuration for Azure resources.

Manages infrastructure for both `team1-front-app` and `team1-back-app` in a single project, since both apps share the same resource group and environment.

## Structure
 
| File | Purpose |
|---|---|
| `main.tf` | Provider config and resource definitions |
| `variables.tf` | Input variable declarations |
| `outputs.tf` | Values exported after apply (resource group name, ID, location) |
| `terraform.tfvars` | Your local variable values — **gitignored, never commit this** |

## Setup

1. Copy the example vars and fill in your values:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Initialise Terraform (downloads the Azure provider):
```bash
terraform init
```

3. Authenticate with Azure:
```bash
az login
```

## Workflow

```bash
terraform fmt       # Format code — run before every commit
terraform validate  # Check for syntax errors
terraform plan      # Preview changes before applying
terraform apply     # Create/update infrastructure
terraform destroy   # Tear down all resources
```

## Variables

| Variable | Description | Default |
|---|---|---|
| `subscription_id` | Azure subscription ID | — |
| `location` | Azure region | `uksouth` |
| `project` | Project name, used in resource names | `team1` |
| `environment` | `dev`, `test`, or `prod` | `dev` |

Resources are named using the pattern `rg-<project>-<environment>`, e.g. `rg-team1-dev`.

## Important

- `terraform.tfvars` and `*.tfstate` are gitignored — state files contain sensitive data
- Deleting resources in the Azure Portal without running `terraform destroy` will cause state drift — Terraform will no longer know about those resources
