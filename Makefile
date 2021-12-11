PROJECT_NAME := opswork-$(shell date '+%s')

init:
	@echo $(PROJECT_NAME) > .projectname

create:
	@PROJECT_NAME=$(shell cat .projectname) && \
	VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text) && \
	SUBNET_IDS=$(aws ec2 describe-subnets --query "Subnets[].SubnetId" --output text) && \
	(aws cloudformation deploy \
		--capabilities CAPABILITY_NAMED_IAM \
		--template-file opswork.yml \
		--stack-name $${PROJECT_NAME} \
		--parameter-overrides \
			DefaultVpcId=$${VPC_ID} \
			DefaultSubnets=$${SUBNET_IDS} \
		    opsWorksStackName=$${PROJECT_NAME}  > /dev/null & ) && \
			./dump/cf_events.sh $${PROJECT_NAME}

destroy:
	@PROJECT_NAME=$(shell cat .projectname) && \
	(aws cloudformation delete-stack \
		--stack-name $${PROJECT_NAME}  > /dev/null & ) && \
    	./dump/cf_events.sh $${PROJECT_NAME}
