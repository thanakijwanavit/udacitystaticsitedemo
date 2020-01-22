# Report for static web hosting project 

## 1. Overview of Project

The project aims to upload a website from the [link](https://drive.google.com/open?id=15vQ7-utH7wBJzdAX3eDmO9ls35J5_sEQ) which is provided by udacity. The site is then deployed on S3 web hosting service and served using cloudfront.

## 2. CloudFormation Template

A cloudformation script with aws-cli command line on mac is used instead of the console in this project in order to provide repeatability and for the ease of management.

```AWSTemplateFormatVersion: '2010-09-09'
Description: Project hosting static site udacity
Resources:
  ExampleSiteBucket:
    Type: AWS::S3::Bucket
    Properties:
      AccessControl : PublicRead
      BucketName: udacity-test-site-example
      WebsiteConfiguration:
        IndexDocument: index.html
        ErrorDocument: error.html
  BucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      PolicyDocument:
        Id: udacityTestSiteBucketPolicy
        Version: 2012-10-17
        Statement:
          - Sid: PublicReadForGetBucketObjects
            Effect: Allow
            Principal: '*'
            Action: 's3:GetObject'
            Resource: !Join
              - ''
              - - 'arn:aws:s3:::'
                - !Ref ExampleSiteBucket
                - /*
      Bucket: !Ref ExampleSiteBucket

  CloudFrontDistribution:
    Type: 'AWS::CloudFront::Distribution'
    DependsOn:
    - ExampleSiteBucket
    - BucketPolicy
    Properties:
      DistributionConfig:
        Comment: 'Cloudfront Distribution pointing ALB Origin'
        Origins:
          - DomainName: udacity-test-site-example.s3-website-ap-southeast-1.amazonaws.com
            OriginPath: ""
            Id: testUdacitySiteCloudfront
            CustomOriginConfig:
              HTTPPort: '80'
              HTTPSPort: '443'
              OriginProtocolPolicy: http-only
        Enabled: True
        DefaultCacheBehavior:
          AllowedMethods:
          - GET
          - HEAD
          TargetOriginId: testUdacitySiteCloudfront
          ViewerProtocolPolicy: allow-all
          ForwardedValues:
              QueryString: 'true'
              Cookies:
                Forward: none

Outputs:
  WebsiteURL:
    Value: !GetAtt
      - ExampleSiteBucket
      - WebsiteURL
    Description: URL for website hosted on S3
  S3BucketSecureURL:
    Value: !Join
      - ''
      - - 'https://'
        - !GetAtt
          - ExampleSiteBucket
          - DomainName
    Description: Name of S3 bucket to hold website content
  CloudFrontURL:
    Value: !GetAtt
      - CloudFrontDistribution
      - DomainName
    Description: Cloud formation url
```

### 2.1 S3 Bucket

A bucket with the name of ```udacity-test-site-example``` is created with a public read only permission with website hosting index page ```index.html```. 



### 2.2 S3 Policy

A bucket policy is created in order to allow the public to send get request to its endpoint. It points to the bucket ```udacity-test-site-example```



### 2.3 CloudFront

A cloudfront Distribution is configured in order to allow it to manage the endpoint providing functions such as caching. The origin domain points to ```udacity-test-site-example.s3-website-ap-southeast-1.amazonaws.com``` which is given by the S3 bucket hosting



## 3. Output endpoints from the cloudformation script

### 3.1 deploy the cloudformation template

Cloudformation template is deployed using a startup script in conjunction with aws-cli tool

```
aws cloudformation create-stack --stack-name exampleSiteUdacity --template-body file://formation.yml
```

### 3.1.1 deployment 

Cloudformation command line tool creates all the artifacts described in section 2 automatically

### 3.1.2 uploading files to s3

The following script is used to copy website objects to the s3 endpoint

```aws s3 cp --recursive ./udacity-starter-website/ s3://udacity-test-site-example/``` 

### 3.2 Obtain the endpoints

``` aws cloudformation describe-stacks --stack-name exampleSiteUdacity ``` 

Outputs of the cloudformation inspect script above gives us insights into the endpoints and success of the script.

```{
    "Stacks": [
        {
            "StackId": "arn:aws:cloudformation:ap-southeast-1:277726656832:stack/exampleSiteUdacity/3a0cefb0-3ccd-11ea-9f76-02da6099db56",
            "StackName": "exampleSiteUdacity",
            "Description": "Project hosting static site udacity",
            "CreationTime": "2020-01-22T04:11:43.365Z",
            "LastUpdatedTime": "2020-01-22T12:22:57.894Z",
            "RollbackConfiguration": {},
            "StackStatus": "UPDATE_IN_PROGRESS",
            "DisableRollback": false,
            "NotificationARNs": [],
            "Outputs": [
                {
                    "OutputKey": "CloudFrontURL",
                    "OutputValue": "d17qdrfwc28fiq.cloudfront.net",
                    "Description": "Cloud formation url"
                },
                {
                    "OutputKey": "S3BucketSecureURL",
                    "OutputValue": "https://udacity-test-site-example.s3.amazonaws.com",
                    "Description": "Name of S3 bucket to hold website content"
                },
                {
                    "OutputKey": "WebsiteURL",
                    "OutputValue": "http://udacity-test-site-example.s3-website-ap-southeast-1.amazonaws.com",
                    "Description": "URL for website hosted on S3"
                }
            ],
            "Tags": [],
            "EnableTerminationProtection": false,
            "DriftInformation": {
                "StackDriftStatus": "NOT_CHECKED"
            }
        }
    ]
}
```

Cloudfront URL can be used to access the website directly 



## 4. Checking in console and website endpoints

### 4.1 CloudFormation

Event Logs

![](https://tva1.sinaimg.cn/large/006tNbRwgy1gb5mqskmqfj320m0u0jxv.jpg)

CloudFormation Resources

![](![](https://tva1.sinaimg.cn/large/006tNbRwgy1gb5myhm60ij31bm0s0gp5.jpg)

### 4.2 S3 Bucket

S3 bbucket viewed from the aws console

![](https://tva1.sinaimg.cn/large/006tNbRwgy1gb5n03agcvj31qw0u0gsj.jpg)

### 4.3 S3 Bucket Policy

S3 bucket Policy screenshot

![](https://tva1.sinaimg.cn/large/006tNbRwgy1gb5n2wzaw6j317o0na78o.jpg)

### 4.4 Cloudfront

![](https://tva1.sinaimg.cn/large/006tNbRwgy1gb5n50nquvj316z0u0q94.jpg)

### 4.5 Website

![](https://tva1.sinaimg.cn/large/006tNbRwgy1gb5n6dfsysj31280u018u.jpg)