locals {
  db_host     = "${var.postgres_name}.internal.${var.env_default_domain}"
  db_user     = "team1"
  db_password = "team1pass"
  db_name     = "team1"
}

# -------------------------------------------------------------------
# PostgreSQL Container App — internal only
# Resets on restart; backend runs migrations on startup via entrypoint.sh
# -------------------------------------------------------------------
resource "azurerm_container_app" "postgres" {
  name                         = var.postgres_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  ingress {
    external_enabled = false
    target_port      = 5432
    exposed_port     = 5432
    transport        = "tcp"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "postgres"
      image  = "postgres:16"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "POSTGRES_USER"
        value = local.db_user
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = local.db_password
      }
      env {
        name  = "POSTGRES_DB"
        value = local.db_name
      }
    }
  }
}

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

      # ---- DB connection — internal postgres CA, plain env vars ----
      env {
        name  = "DB_HOST"
        value = local.db_host
      }
      env {
        name  = "DB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_USER"
        value = local.db_user
      }
      env {
        name  = "DB_PASSWORD"
        value = local.db_password
      }
      env {
        name  = "DB_NAME"
        value = local.db_name
      }
      env {
        name  = "DB_SCHEMA"
        value = "public"
      }

      # ---- Secrets from Key Vault (non-DB) ----
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

  # Key Vault secret references (non-DB only)
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

  depends_on = [azurerm_container_app.postgres]
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
