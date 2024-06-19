# puc_devops_iac_terraform_azure
Azure Terraform project for learning purposes.

## Pre-Requirements
- Install Terraform
- Install Azure CLI


## Infrastructure architecture:

![infra](./img/infrastructure.png)

### Goal -> Resources created (example):

![resource](./img/resources.png)

## Build
- Add your credentials to terraform.tfvars or providers.tf.

- Deploy:
``` 
terraform init
terraform plan -out main.tfplan
terraform apply "main.tfplan" 
```

- Remove resources (destroy):
```
terraform plan -destroy -out main.destroy.tfplan
terraform apply "main.destroy.tfplan"
```


