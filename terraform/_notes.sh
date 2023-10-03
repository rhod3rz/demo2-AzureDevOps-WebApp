terraform init -reconfigure -backend-config="key=env-prd.tfstate"
terraform fmt -recursive
terraform validate
terraform plan -var-file="vars/global.tfvars" -var-file="vars/env-prd.tfvars" -detailed-exitcode
terraform apply -var-file="vars/global.tfvars" -var-file="vars/env-prd.tfvars"
terraform destroy -var-file="vars/global.tfvars" -var-file="vars/env-prd.tfvars"


terraform init -reconfigure -backend-config="key=env-dev.tfstate"
terraform fmt -recursive
terraform validate
terraform plan -var-file="vars/global.tfvars" -var-file="vars/env-dev.tfvars" -detailed-exitcode
terraform apply -var-file="vars/global.tfvars" -var-file="vars/env-dev.tfvars"
terraform destroy -var-file="vars/global.tfvars" -var-file="vars/env-dev.tfvars"
