# faasd for AWS

This repo contains a Terraform Module for how to deploy a [faasd](https://github.com/openfaas/faasd) instance on the
[AWS](https://aws.amazon.com/) using [Terraform](https://www.terraform.io/).

__faasd__, a lightweight & portable faas engine, is [OpenFaaS](https://github.com/openfaas/) reimagined, but without the cost and complexity of Kubernetes. It runs on a single host with very modest requirements, making it fast and easy to manage. Under the hood it uses [containerd](https://containerd.io/) and [Container Networking Interface (CNI)](https://github.com/containernetworking/cni) along with the same core OpenFaaS components from the main project.

## What's a Terraform Module?

A Terraform Module refers to a self-contained packages of Terraform configurations that are managed as a group. This repo
is a Terraform Module and contains many "submodules" which can be composed together to create useful infrastructure patterns.

## How do you use this module?

This repository defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this repository:

```hcl
module "faasd" {
  source = "github.com/jsiebens/terraform-aws-faasd"

  name      = "faasd"
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
  key_name  = var.key_name
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 3.30.0 |
| random | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.30.0 |
| random | >= 3.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.faasd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.faasd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.faasd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.faasd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.faasd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_instance | The instance type to use for the instance. | `string` | `"t2.small"` | no |
| basic\_auth\_password | The basic auth password, if left empty, a random password is generated. | `string` | `null` | no |
| basic\_auth\_user | The basic auth user name. | `string` | `"admin"` | no |
| domain | A public domain for the faasd instance. This will the use of Caddy and a Let's Encrypt certificate | `string` | `""` | no |
| email | Email used to order a certificate from Let's Encrypt | `string` | `""` | no |
| key\_name | Key name of the Key Pair to use for the instance. | `string` | n/a | yes |
| name | The name of the faasd instance. | `string` | n/a | yes |
| subnet\_id | VPC Subnet ID to launch in. | `string` | n/a | yes |
| tags | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| vpc\_id | VPC ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| basic\_auth\_password | The basic auth password. |
| basic\_auth\_user | The basic auth user name. |
| gateway\_url | The url of the faasd gateway |
| ipv4\_address | The public IP address of the faasd instance |
<!-- END_TF_DOCS -->

## See Also

- [faasd on Google Cloud Platform](https://github.com/jsiebens/terraform-google-faasd)
- [faasd on AWS](https://github.com/jsiebens/terraform-aws-faasd)
- [faasd on Microsoft Azure](https://github.com/jsiebens/terraform-azurerm-faasd)
- [faasd on DigitalOcean](https://github.com/jsiebens/terraform-digitalocean-faasd)
- [faasd on Equinix Metal](https://github.com/jsiebens/terraform-equinix-faasd)