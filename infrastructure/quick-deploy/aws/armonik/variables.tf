# Profile
variable "profile" {
  description = "Profile of AWS credentials to deploy Terraform sources"
  type        = string
  default     = "default"
}

# Region
variable "region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "eu-west-3"
}

# Kubeconfig path
variable "k8s_config_path" {
  description = "Path of the configuration file of K8s"
  type        = string
  default     = "~/.kube/config"
}

# Kubeconfig context
variable "k8s_config_context" {
  description = "Context of K8s"
  type        = string
  default     = "default"
}

# Kubernetes namespace
variable "namespace" {
  description = "Kubernetes namespace for ArmoniK"
  type        = string
  default     = "armonik"
}

# Logging level
variable "logging_level" {
  description = "Logging level in ArmoniK"
  type        = string
  default     = "Information"
}

# List of needed storage
variable "storage_endpoint_url" {
  description = "List of storage needed by ArmoniK"
  type        = any
  default     = {}
}

# Monitoring
variable "monitoring" {
  description = "Endpoint URL of monitoring"
  type        = any
  default     = {}
}


# Extra configuration
variable "extra_conf" {
  description = "Add extra configuration in the configmaps"
  #type = object({
  #  compute = optional(map(string), {})
  #  control = optional(map(string), {})
  #  core    = optional(map(string), {})
  #  log     = optional(map(string), {})
  #  polling = optional(map(string), {})
  #  worker  = optional(map(string), {})
  #})
  type    = any
  default = {}
}

# Job to insert partitions in the database
variable "job_partitions_in_database" {
  description = "Job to insert partitions IDs in the database"
  type = object({
    name               = string
    image              = string
    tag                = string
    image_pull_policy  = string
    image_pull_secrets = string
    node_selector      = any
    annotations        = any
  })
}

# Parameters of control plane
variable "control_plane" {
  description = "Parameters of the control plane"
  type = object({
    name              = string
    service_type      = string
    replicas          = number
    image             = string
    tag               = string
    image_pull_policy = string
    port              = number
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
    image_pull_secrets = string
    node_selector      = any
    annotations        = any
    # KEDA scaler
    hpa               = any
    default_partition = string
  })
}

# Parameters of admin gui
variable "admin_gui" {
  description = "Parameters of the admin GUI"
  type = object({
    name  = string
    image = string
    tag   = string
    port  = number
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
    service_type       = string
    replicas           = number
    image_pull_policy  = string
    image_pull_secrets = string
    node_selector      = any
  })
  default = null
}

variable "admin_old_gui" {
  description = "Parameters of the old admin GUI"
  type = object({
    api = object({
      name  = string
      image = string
      tag   = string
      port  = number
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
    old = object({
      name  = string
      image = string
      tag   = string
      port  = number
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
    service_type       = string
    replicas           = number
    image_pull_policy  = string
    image_pull_secrets = string
    node_selector      = any
  })
  default = null
}

# Parameters of the compute plane
variable "compute_plane" {
  description = "Parameters of the compute plane"
  type = map(object({
    replicas                         = number
    termination_grace_period_seconds = number
    image_pull_secrets               = string
    node_selector                    = any
    annotations                      = any
    polling_agent = object({
      image             = string
      tag               = string
      image_pull_policy = string
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
    worker = list(object({
      name              = string
      image             = string
      tag               = string
      image_pull_policy = string
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    }))
    # KEDA scaler
    hpa = any
  }))
}

variable "ingress" {
  description = "Parameters of the ingress controller"
  type = object({
    name              = string
    service_type      = string
    replicas          = number
    image             = string
    tag               = string
    image_pull_policy = string
    http_port         = number
    grpc_port         = number
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
    image_pull_secrets    = string
    node_selector         = any
    annotations           = any
    tls                   = bool
    mtls                  = bool
    generate_client_cert  = bool
    custom_client_ca_file = string
  })
}

# Authentication behavior
variable "authentication" {
  description = "Authentication behavior"
  type = object({
    name                    = string
    image                   = string
    tag                     = string
    image_pull_policy       = string
    image_pull_secrets      = string
    node_selector           = any
    authentication_datafile = string
    require_authentication  = bool
    require_authorization   = bool
  })
}