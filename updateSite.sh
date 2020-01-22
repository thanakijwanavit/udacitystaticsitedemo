bash ./checkTemplate.sh && \
aws cloudformation update-stack --stack-name exampleSiteUdacity --template-body file://formation.yml
bash ./describeStack.sh
