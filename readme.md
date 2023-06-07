# Create EKS Cluster in AWS Using Terraform
This code creates VPC, IAM Role, EKS and Ingress Controller Using Terraform.

## Installation of required AWS packages
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- Configure [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/configure/)
- Please note, Configuring AWS using `aws configure` CLI command, will write the AWS secret and access key to `~/$USER_HOME/.aws/credentials` file and it will used to authenticate the terraform infra creation in AWS.
- EKSCTL

##  Install and Configure Terraform
- Refer here [for installing terraform](https://www.terraform.io/downloads.html)
- Extract and Add `terraform` executable path to ENV variables

## Terraform setup in Linux based systems
```
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip -d terraform /usr/local/bin/
```
If terraform executable stored in another path, make sure the path is added in `$PATH` variable permanently.


## Follow the steps here
https://medium.com/devops-mojo/terraform-provision-amazon-eks-cluster-using-terraform-deploy-create-aws-eks-kubernetes-cluster-tf-4134ab22c594

https://antonputra.com/terraform/how-to-create-eks-cluster-using-terraform/#create-iam-oidc-provider-eks-using-terraform

https://github.com/RobinNagpal/kubernetes-tutorials/blob/master/06_tools/007_alb_ingress/01_eks/Makefile

https://www.techtarget.com/searchcloudcomputing/tutorial/How-to-deploy-an-EKS-cluster-using-Terraform


Apply terraform files:
	terraform init
    terraform plan
    terraform validate
    terraform apply 
(NB: you will get a prompt for the project name. For example: 
my project name is mavenapp. The code will create the EKS
Cluster named - mavenapp-cluster)  
	
Update your kube config:
	aws eks --region us-east-2 update-kubeconfig --name mavenapp-cluster

Create service account using the eks-service-account.yaml file:
	kubectl apply -f eks/eks-service-account.yaml

Validate the service account:
	kubectl get sa aws-load-balancer-controller -n kube-system

Deploy Ingress controller:
	helm repo add eks https://aws.github.io/eks-charts
	helm repo update
	
	helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
	  -n kube-system \
	  --set clusterName=mavenapp-cluster \
	  --set serviceAccount.create=false \
	  --set serviceAccount.name=aws-load-balancer-controller 

Validate the Ingress controller is running: 
	kubectl get deployment -n kube-system aws-load-balancer-controller
	or
	helm list -n kube-system

Test the EKS and Ingress by deploying a sample game app:
I already deployed the image to my ecr, so I pulled the image from my ECR. You can use the image below
In public ecr repo. Change the image in the file to this one:
image: public.ecr.aws/l6m2t8p7/docker-2048:latest
	kubectl apply -f eks/2048_full.yaml

Validate the app is deployed:
	kubectl get pods -n game-2048
	kubectl get svc -n game-2048
	kubectl get ing -n game-2048

Validate the Load Balancer is working:
	kubectl get ing -n game-2048
	# pick the Load Balancer ADDRESS from the above result.
	
From a web browser:
	ADDRESS:80

Delete the app used for testing (optional):
	kubectl delete -f eks/2048_full.yaml



Shutdown process

Delete the application: 
	kubectl delete -f 2048_full.yaml
	kubectl delete -f eks-deploy-k8s.yaml 

Delete the service account:
	eksctl delete iamserviceaccount \
	  --cluster=mavenapp-cluster \
	  --namespace=kube-system \
	  --name=aws-load-balancer-controller

terraform destroy -auto-approve

Stop jenkins server

Stop sonarqube server
# deploy-eks-using-terraform
