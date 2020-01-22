bash ./checkTemplate.sh
aws cloudformation create-stack --stack-name exampleSiteUdacity --template-body file://formation.yml
bash ./describeStack.sh

sleep 60
aws s3 cp --recursive ./udacity-starter-website/ s3://udacity-test-site-example/