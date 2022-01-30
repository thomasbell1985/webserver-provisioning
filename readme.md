# About

This repository contains terraform and ansible for provisioning N nginx servers in an Amazon VPC. This repository will provision all networking, ami's, security groups, and installing nginx on all servers.

## Dependencies

In order to run the the code in this repsository there are a view dependencies that you will need to have installed on whatever server you run from.

* [Terraform >=0.14.9](https://www.terraform.io/downloads)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 
* [Jinja2-CLI](https://pypi.org/project/jinja2-cli/)
* [jq](https://stedolan.github.io/jq/)

## Setup

To execute the scripts in this repository you will need to create a tfvars file in terraform directory. The tfvars will look something like this:

```ini
# Required
public_ssh_key="<some public key installed in your ssh identities>"
# Optional
vpc_name="somename" # default terraform_vpc
vpc_cidr="10.0.0.0/16" # default 10.0.0.0/16
public_subnets=["10.0.1.0/24"] # default ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets=[] # default []
# the aws profile to use when provisioning
profile="default" # default "default"
profile="us-west-1" # default "region"
```

You will also need to initialize the terraform providers:

```
cd terraform
terraform init
```

The file name should be my.tfvars

```sh
terraform/my.tfvars
```

As listed above the public_ssh_key is the key used to connect to the remote servers. This can be your standard id_rsa.pub; on most unix distributions you can get this value from:

```sh
cat ~/.ssh/id_rsa.pub
```

If you want or need to generate a new key pare you can follow instructions [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)


## Running

To run the full provisioning script you can run the build.sh file from the root directory:

```sh
./build.sh
```

This will run all the necessary scripts, but it will prompt for input twice: first to confirm creation of the VPC and second to confirm creation of all other resources. Once all resources are created, if everything went correctly, then you should now be able to access each of the nginx servers on port 80. To get the ips you can read the terraform output:

```sh
# get the ip addresses
terraform -chdir=terraform/  output -json | jq "{webservers:.webserver_ips.value}"

{
  "webservers": [
    "3.234.254.82",
    "34.203.232.173",
    "34.229.73.154"
  ]
}

# use curl to ensure everything works:
curl http://3.234.254.92 # use the ips created from above.

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
........
```

To destroy the resources you can simply call destroy from the terraform directory:

```sh
cd terraform
terraform destroy -var-file=my.tfvars
```

## Considerations

For this repository you will need to initialize the VPC before running the rest of the code, you can do this manually by running:

```sh
terraform -chdir=terraform/ apply -target module.vpc -var-file=my.tfvars
```

Or you can just run the build.sh file as outlined above. The reason for this is because the ami's need to have a subnet-id from the vpc module. This is something that needs to be figured out in a future release.

## Security

By default the build.sh will disable strict host checking when executing the ansible command. This will ensure you won't need to manually add the hosts to your known_hosts file.

If you wish to run with host checking, then you can run each step independently and manually add the host to your known hosts before executing the ansible playbook.

## TODO:

1. Add application load balancer to balance traffic to instances
1. Add autoscaling group