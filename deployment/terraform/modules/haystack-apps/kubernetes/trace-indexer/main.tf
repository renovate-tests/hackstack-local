locals {
  app_name = "trace-indexer"
  config_file_path = "${path.module}/config/trace-indexer.conf"
  container_config_path = "/config/trace-indexer.conf"
  count = "${var.enabled?1:0}"
}


resource "kubernetes_config_map" "haystack-ui" {
  metadata {
    name = "${local.app_name}"
    namespace = "${var.namespace}"
  }

  data {
    "trace-indexer.conf" = "${file("${local.config_file_path}")}"
  }
}

resource "kubernetes_replication_controller" "haystack-rc" {
  metadata {
    name = "${local.app_name}"
    labels {
      app = "${local.app_name}"
    }
    namespace = "${var.namespace}"
  }
  "spec" {
    replicas = "${var.replicas}"
    template {
      container {
        image = "${var.image}"
        name = "${local.app_name}"
        env {
          name = "HAYSTACK_OVERRIDES_CONFIG_PATH"
          value = "${local.container_config_path}"
        }
        volume_mount {
          mount_path = "/config"
          name = "config-volume"
        }
      }
      termination_grace_period_seconds = "${var.termination_grace_period}"
      volume {
        name = "config-volume"
        config_map {
          name = "${kubernetes_config_map.haystack-ui.metadata.0.name}"
        }
      }
    }

    "selector" {
      app = "${local.app_name}"
    }
  }
  count = "${local.count}"
}