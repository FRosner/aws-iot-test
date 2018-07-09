```bash
cd terraform && terraform apply -auto-approve -target=aws_s3_bucket.webui; cd -
sbt kinesis/assembly && sbt webui/publish && cd terraform && terraform apply -auto-approve; cd -
cd terraform && $(terraform output | grep 'aws_command' | cut -d'=' -f2) && cd -
```