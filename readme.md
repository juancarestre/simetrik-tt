# Requirements

* Python 3~
* pip
* awscli v2~
* docker
* terraform ~v1.5.5
* se debe aws cli configurado con un usuario con suficientes permisos para poder ejecutar todo

    ```
    aws configure --profile <PROFILE_NAME>
    ```

    Este profile es con el cual se desplegara todo

## Despliegue

Primero se necesita un bucket donde se guardaran los state

```
aws s3 mb s3://<BUCKET_STATES_NAME> --profile <PROFILE_NAME>
```

Otorgar permisos de ejecucion al script que se trae el THUMBPRINT del cluster para que todo sea automatizado

```
chmod +x eks/thumbprint.sh
```

Se debe llenar el tf_backend.conf con los valores requeridos

```conf
bucket="<BUCKET_STATES_NAME>"
key="tt/dev"
region="<AWS_REGION>"
profile="<AWS_PROFILE>"
```

Se debe inicializar el backend s3 (no use lock con dynamodb ya que al trabajar solo no lo vi necesario)


```
terraform init -backend-config=tf_backend.conf
```


Aplicar los dos primeros modulos, no se aplican los demas porque el provider de kubernetes depende de datos que son salida de module.eks y terraform plan intenta incializar todos los providers

```
terraform apply -target=module.network -target=module.eks
```

Se aplican el resto de recursos

```
terraform apply
```