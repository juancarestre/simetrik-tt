
aws s3 mb s3://simetrik-tt-tfstates --profile juan
chmod +x eks/thumbprint.sh
terraform init -backend-config=tf_backend.conf
