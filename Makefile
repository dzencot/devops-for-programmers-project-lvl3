terraform-init:
	make -C terraform init

terraform-plan:
	make -C terraform plan

terraform-apply:
	make -C terraform apply

terraform-show:
	make -C terraform show

terraform-destroy:
	make -C terraform destroy

install:
	make -C ansible install

playbook-run:
	make -C ansible playbook-run
