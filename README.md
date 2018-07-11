# AWS IoT Test

## Description

This is the result of my AWS infrastructure Kata involving IoT Core, Kinesis, Lambda, ElastiCache, Elastic Beanstalk, and S3.
The goal is to route incoming MQTT messages towards an S3 bucket for persistence, as well as showing some aggregated statistics on a web interface.
For a detailed explanation please refer to the corresponding blog post: [Sensor Data Processing on AWS using IoT Core, Kinesis and ElastiCache](#)

![architecture](https://res.cloudinary.com/practicaldev/image/fetch/s--DQk3izBA--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://thepracticaldev.s3.amazonaws.com/i/1zm11u6uwpo9vi3gureo.png)

## Deployment

The Terraform deployment has to be done in two steps, because unfortunately we cannot upload jar files to Elastic Beanstalk directly. So we first need to create an S3 bucket before we can push the Elastic Beanstalk application version artifact to that bucket.

Afterwards we need to invoke the version deployment manually using the AWS SDK, as Terraform does not support version deployment as of today. So here are the steps:

1. Create S3 artifact bucket
2. Assemble Lambda jar file
3. Assemble and publish web UI jar file to S3
4. Create the remaining infrastructure
5. Deploy web UI application version (see `aws_command` output)

```bash
cd terraform && terraform apply -auto-approve -target=aws_s3_bucket.webui; cd -
sbt kinesis/assembly && sbt webui/publish && cd terraform && terraform apply -auto-approve; cd -
cd terraform && $(terraform output | grep 'aws_command' | cut -d'=' -f2) && cd -
```

## Usage

To send messages you can use the MQTT test tool provided by AWS IoT. 
It is accessible through the AWS IoT Console, navigating to the *Test* section.
When you open the Elastic Beanstalk environment URL you will see the dashboard showing your latest message and a message counter.

![demo](https://thepracticaldev.s3.amazonaws.com/i/lr6mq7pw22ol3r7enzhw.gif)  

Note that because I was too lazy to properly configure the load balancer, the WebSocket connection gets closed after a short period of inactivity.