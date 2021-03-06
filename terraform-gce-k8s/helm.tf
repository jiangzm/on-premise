variable "helm_version" {
  default = "v2.9.1"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

variable "app_name" {
  default = "pm2-on-premise"
}

variable "acme_email" {}

variable "acme_url" {
  default = "https://acme-v01.api.letsencrypt.org/directory"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "terraform-tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "terraform-tiller"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind = "ServiceAccount"
    name = "terraform-tiller"

    api_group = ""
    namespace = "kube-system"
  }
}

provider "helm" {
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:${var.helm_version}"

  kubernetes {
    host                   = "${google_container_cluster.default.endpoint}"
    token                  = "${data.google_client_config.current.access_token}"
    client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"
  }
}

resource "google_compute_address" "default" {
  name   = "tf-gke-helm-${var.app_name}"
  region = "${var.region}"
}

data "template_file" "openapi_spec" {
  template = "${file("${path.module}/openapi_spec.yaml")}"

  vars {
    endpoint_service = "${local.public_domain}"
    target           = "${google_compute_address.default.address}"
  }
}

resource "random_id" "endpoint-name" {
  byte_length = 2
}

resource "google_endpoints_service" "openapi_service" {
  service_name   = "${local.public_domain}"
  project        = "${data.google_client_config.current.project}"
  openapi_config = "${data.template_file.openapi_spec.rendered}"
}

resource "helm_release" "kube-lego" {
  name  = "kube-lego"
  chart = "stable/kube-lego"

  values = [<<EOF
rbac:
  create: false
config:
  LEGO_EMAIL: ${var.acme_email}
  LEGO_URL: ${var.acme_url}
  LEGO_SECRET_NAME: lego-acme
EOF
  ]
}

resource "helm_release" "nginx-ingress" {
  name  = "nginx-ingress"
  chart = "stable/nginx-ingress"

  values = [<<EOF
rbac:
  create: false
controller:
  service:
    loadBalancerIP: ${google_compute_address.default.address}
EOF
  ]

  depends_on = [
    "helm_release.kube-lego",
  ]
}

resource "helm_release" "pm2-on-premise" {
  name = "pm2-on-premise"
  chart = "${path.module}/../helm"

    values = [<<EOF
serviceType: ClusterIP
ingress:
  enabled: true
  hosts:
    - ${local.public_domain}
  tls:
  - hosts:
    - ${local.public_domain}
    secretName: pm2-endpoint-tls
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    ingress.kubernetes.io/ssl-redirect: "true"
EOF
  ]

  depends_on = [
    "kubernetes_secret.regcred",
    "helm_release.kube-lego",
    "helm_release.nginx-ingress",
    "google_container_cluster.default",
  ]
}


output "endpoint" {
  value = "${local.public_domain}"
}