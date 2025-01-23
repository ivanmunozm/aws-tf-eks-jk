locals {
  sufix = "${var.tags.project}-${var.tags.env}-${var.tags.region}" # recurso-pegaso-prod-region
}

resource "random_string" "sufijo-s3" {
  length  = 8
  special = false
  upper   = false

}

locals {
  s3-sufix = "${var.tags.project}-${var.tags.env}-${var.tags.region}-${random_string.sufijo-s3.result}"
}