data "template_file" "bootstrap" {
  template = file(format("%s/scripts/bootstrap.tpl", path.module))
  vars={
    GIT_REPO="https://github.com/stackitgit/CliXX_Retail_Repository.git"
    file_system_id = aws_efs_file_system.stack_efs.id
    MOUNT_POINT    = var.MOUNT_POINT
  
    REGION         = var.AWS_REGION
    ALB_DNS        = aws_lb.CliXX-LB.dns_name
    DB_USER        = local.clixx_creds.DB_USER
    DB_NAME        = local.clixx_creds.DB_NAME
    DB_PASSWORD    = local.clixx_creds.DB_PASSWORD
    DB_HOST        = split(":", aws_db_instance.clixx[0].endpoint)[0]

  }
}


