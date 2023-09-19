echo [application_servers] > hosts
terraform -chdir="./infrastructure/terraform" output -json | jq -r '.app_servers_ips.value.internal[][]' >> hosts
echo [load_balancer] >> hosts
terraform -chdir="./infrastructure/terraform" output -json | jq -r '.load_balancer_ips.value.external[][]' >> hosts
echo [monitoring] >> hosts
terraform -chdir="./infrastructure/terraform" output -json | jq -r '.monitoring_ips.value.internal[][]' >> hosts
