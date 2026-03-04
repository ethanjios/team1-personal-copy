# -------------------------------------------------------------------
# Backend Container App — internal only (not exposed to the internet)
# -------------------------------------------------------------------
resource "azurerm_container_app" "backend" {
  name                         = var.backend_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.managed_identity_id
  }

  ingress {
    external_enabled = false
    target_port      = 3001
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "backend"
      image  = "${var.acr_login_server}/${var.backend_image}"
      cpu    = 0.25
      memory = "0.5Gi"

      # ---- Plain env vars ----
      env {
        name  = "PORT"
        value = "3001"
      }
      # Allow CORS from the frontend's public URL
      env {
        name  = "FRONTEND_URL"
        value = "https://${var.frontend_name}.${var.env_default_domain}"
      }
      env {
        name  = "ENABLE_JOB_APPLICATIONS"
        value = var.enable_job_applications
      }
      env {
        name  = "ENABLE_ADD_JOB_ROLE"
        value = var.enable_add_job_role
      }

      # ---- Secrets pulled from Key Vault at runtime ----
      env {
        name        = "DB_USER"
        secret_name = "db-user"
      }
      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }
      env {
        name        = "DB_HOST"
        secret_name = "db-host"
      }
      env {
        name        = "DB_PORT"
        secret_name = "db-port"
      }
      env {
        name        = "DB_NAME"
        secret_name = "db-name"
      }
      env {
        name        = "DB_SCHEMA"
        secret_name = "db-schema"
      }
      env {
        name        = "JWT_SECRET"
        secret_name = "jwt-secret"
      }
      env {
        name        = "AWS_REGION"
        secret_name = "aws-region"
      }
      env {
        name        = "AWS_ACCESS_KEY_ID"
        secret_name = "aws-access-key-id"
      }
      env {
        name        = "AWS_SECRET_ACCESS_KEY"
        secret_name = "aws-secret-access-key"
      }
      env {
        name        = "S3_BUCKET_NAME"
        secret_name = "s3-bucket-name"
      }
    }
  }

  # Key Vault secret references — fetched using the managed identity
  # Secret names in Key Vault must be created manually in the portal first
  secret {
    name                = "db-user"
    key_vault_secret_id = "${var.key_vault_uri}secrets/DbUser"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "db-password"
    key_vault_secret_id = "${var.key_vault_uri}secrets/DbPassword"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "db-host"
    key_vault_secret_id = "${var.key_vault_uri}secrets/DbHost"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "db-port"
    key_vault_secret_id = "${var.key_vault_uri}secrets/DbPort"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "db-name"
    key_vault_secret_id = "${var.key_vault_uri}secrets/DbName"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "db-schema"
    key_vault_secret_id = "${var.key_vault_uri}secrets/DbSchema"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "jwt-secret"
    key_vault_secret_id = "${var.key_vault_uri}secrets/JwtSecret"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "aws-region"
    key_vault_secret_id = "${var.key_vault_uri}secrets/AwsRegion"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "aws-access-key-id"
    key_vault_secret_id = "${var.key_vault_uri}secrets/AwsAccessKeyId"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "aws-secret-access-key"
    key_vault_secret_id = "${var.key_vault_uri}secrets/AwsSecretAccessKey"
    identity            = var.managed_identity_id
  }
  secret {
    name                = "s3-bucket-name"
    key_vault_secret_id = "${var.key_vault_uri}secrets/S3BucketName"
    identity            = var.managed_identity_id
  }
}

# -------------------------------------------------------------------
# Frontend Container App — public (external ingress enabled)
# -------------------------------------------------------------------
resource "azurerm_container_app" "frontend" {
  name                         = var.frontend_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.managed_identity_id
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "frontend"
      image  = "${var.acr_login_server}/${var.frontend_image}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "PORT"
        value = "3000"
      }
      # Internal URL — accessible only within the Container App Environment
      env {
        name  = "API_BASE_URL"
        value = "https://${var.backend_name}.internal.${var.env_default_domain}"
      }
      env {
        name  = "ENABLE_JOB_APPLICATIONS"
        value = var.enable_job_applications
      }
      env {
        name  = "ENABLE_ADD_JOB_ROLE"
        value = var.enable_add_job_role
      }
    }
  }
}
