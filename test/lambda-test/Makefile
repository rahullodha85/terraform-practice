all: build init plan apply

build:
	cd ./src; GOOS=linux GOARCH=amd64 go build -o ../output/app

init:
	 terraform init

plan:
	terraform plan

apply:
	terraform apply --auto-approve

destroy:
	terraform destroy --auto-approve