#!/bin/bash
echo "Provisioning VPC...." &&
terraform -chdir=terraform/ apply -target module.vpc -var-file=my.tfvars &&
echo "Provisioning webservers...." &&
terraform -chdir=terraform/ apply -var-file=my.tfvars &&
terraform -chdir=terraform/  output -json | jq "{webservers:.webserver_ips.value}" > data.json && jinja2 ansible/templates/inventory_template.j2 data.json  --format=json > ansible/inventory.ini
echo "Installing nginx......" &&
export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ansible/inventory.ini -u ubuntu  ansible/webserver_playbook.yaml
echo "Provisioning complete, cleaning up....." &&
rm data.json
echo "All done :)."
