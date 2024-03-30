# Requerimientos

* Python ~3
* PIP
* Awscli ~v2
* Docker
* Terraform ~v1.5.5
* Se debe configurar aws cli con un profile de un usuario con suficientes permisos para crear todos los recursos

    ```
    aws configure --profile <PROFILE_NAME>
    ```

    **Este profile es con el cual se desplegara todo**


# Guia de despliegue

## TLDR (solo si estas de afan hazlo asi, si tienes tiempo ve a: [Guia de despliegue paso a paso](#GuiaDeDesplieguePasoAPaso))

crea un archivo .env en infra/.env con esta forma modificando los respectivos valores:

```bash
aws_profile=juan
aws_account_id=597701726802
OPENAI_API_KEY=TE_LA_ENVIE_POR_CORREO
AWS_ACCESS_KEY_ID=nmp
AWS_ACCESS_KEY_SECRET="asd"
TF_STATE_BUCKET="unbucketquenoexista"
AWS_REGION=us-east-1
```


Para inicializar el proyecto:
```bash
cd infra
chmod +x initial.sh
./initial.sh
```


Para desplegar:
```bash
terraform init -backend-config=tf_backend.conf
terraform plan -target=module.network -target=module.eks
terraform apply -target=module.network -target=module.eks -auto-approve
terraform plan
terraform apply -auto-approve
```

Para borrar todo:

```bash
terraform destroy
```


## GuiaDeDesplieguePasoAPaso

El proyecto se divide en dos partes `apps/` e `infra/`, en `apps/` se guardaran las aplicaciones `nea-translator` y `nea-translator-grpc-server`, para entender mas sobre ellas ir a la seccion de: [Aplicaciones](#Aplicaciones), en `infra/` esta todo el codigo para realizar el despliegue (Terraform y un poco de bash)

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

# GuiaDeDesplieguePasoAPaso

# Aplicaciones