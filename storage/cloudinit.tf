//provider "cloudinit" {}

data "template_file" "cloud-init-script" {
  template = file("${path.module}/scripts/init.cfg")
}

data "template_file" "shell-script" {
  template = file("${path.module}/scripts/volume-mount.sh")
  vars = {
    DEVICE_NAME = var.DEVICE_NAME
    VOLUME_NAME = var.VOLUME_NAME
  }
}

data "template_cloudinit_config" "cloudinit-storage" {
  gzip          = false
  base64_encode = false
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud-init-script.rendered
  }

  part {
    filename     = "volume-mount.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}

output "cloudinit-storage-template" {
  value = data.template_cloudinit_config.cloudinit-storage.rendered
}

