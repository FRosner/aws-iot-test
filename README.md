```bash
cd terraform && terraform apply -auto-approve -target=aws_s3_bucket.webui; cd -
sbt kinesis/assembly && sbt webui/publish && cd terraform && terraform apply -auto-approve; cd -
```