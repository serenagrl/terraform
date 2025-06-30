resource "alicloud_kms_instance" "kms" {
  count = local.kms.enabled ? 1 : 0

  instance_name = "${local.project}-kms"
  payment_type                = "PayAsYouGo"
  vpc_id                      = alicloud_vpc.vpc.id
  zone_ids                    = alicloud_vswitch.private_vswitches.*.zone_id
  vswitch_ids                 = [ alicloud_vswitch.service_vswitch.0.id ]
  force_delete_without_backup = true

  depends_on = [
    alicloud_vswitch.service_vswitch,
    alicloud_vswitch.private_vswitches
  ]
}

resource "alicloud_kms_key" "key" {
  count = local.kms.enabled ? 1 : 0

  description            = "${local.project} KMS Key."
  status                 = "Enabled"
  protection_level       = "SOFTWARE"
  key_usage              = "ENCRYPT/DECRYPT"
  pending_window_in_days = "7"
  dkms_instance_id       = alicloud_kms_instance.kms.0.id

  depends_on = [ alicloud_kms_instance.kms ]
}