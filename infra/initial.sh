
#!/bin/bash

if [[ -f ".env" ]]; then
    source ".env"
else
    echo "No se encontró el archivo config.env"
    exit 1
fi

aws sts get-caller-identity --profile ${aws_profile}
aws s3 mb "s3://${TF_STATE_BUCKET}" --profile "${aws_profile}" --region "${AWS_REGION}"

echo "aws_profile           = \"${aws_profile}\"
aws_account_id        = \"${aws_account_id}\"
OPENAI_API_KEY        = \"${OPENAI_API_KEY}\"
AWS_ACCESS_KEY_ID     = \"${AWS_ACCESS_KEY_ID}\"
AWS_ACCESS_KEY_SECRET = \"${AWS_ACCESS_KEY_SECRET}\"
aws_region            = \"${AWS_REGION}\"" > terraform.tfvars


echo "bucket=\"${TF_STATE_BUCKET}\"
key=\"tt/dev\"
region=\"${AWS_REGION}\"
profile=\"${aws_profile}\"" > tf_backend.conf

chmod +x eks/thumbprint.sh
