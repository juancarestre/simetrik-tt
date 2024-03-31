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

* El usuario que ejecuta terraform debe tener permisos para ejecutar docker (Ya que estoy buildeando las imagenes de las apps durante el proceso)

# Diagrama de arquitectura

![arquitectura](simetrik.drawio.png)

# Explicacion rapida

Tengo las apps y la infra separadas, no me gusta usar terraform para aprovisionar codigo (osea usar terraform dentro del proceso de CD) pero dado que la prueba requeria desplegar las apps con un modulo hice lo siguiente

* modulo `networking`: crea todo lo de vpc, subnets, igw, nat, ECT
* modulo `eks`: crea un cluster de eks con lo minimo necesariopara andar (addons, cni, coredns, nodegroups, ETC)
* modulo `loadbalancercontroller`: el controlador para permitir la creacion de ALBs bajo demanda de ingress
* modulo `k8s_apps`: define los manifiestos de kubernetes para las aplicaciones y todo lo que necesitan

De esta manera se desligan las aplicaciones de la infraestructura, siendo asi que si hay cambios en las apps el unico modulo que detectara cambios es `k8s_apps` y no el modulo `eks` (que desde mi punto de vista solo debe desplegar un cluster con lo minimo necesario)

Se usaron varios providers: aws, helm, y kubernetes

# Guia de despliegue

## TLDR (solo si estas de afan hazlo asi, si tienes tiempo ve a: [Guia de despliegue paso a paso](#guia-de-despliegue-paso-a-paso)

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


## Guia de despliegue paso a paso

El proyecto se divide en dos partes `apps/` e `infra/`, en `apps/` se guardaran las aplicaciones `nea-translator` y `nea-translator-grpc-server`, para entender mas sobre ellas ir a la seccion de: [Aplicaciones](#aplicaciones), en `infra/` esta todo el codigo para realizar el despliegue (Terraform y un poco de bash)

Verifica que tienes los [Requerimientos](#requerimientos)


Debes crear un bucket donde se guardaran los `tfstate`

```
aws s3 mb s3://<BUCKET_STATES_NAME> --profile <AWS_PROFILE>
```

Otorgar permisos de ejecucion al script que se trae el `THUMBPRINT` del cluster para que todo sea automatizado

```
chmod +x infra/eks/thumbprint.sh
```

Se debe llenar el `tf_backend.conf` con los valores requeridos

```conf
bucket="<BUCKET_STATES_NAME>"
key="tt/dev"
region="<AWS_REGION>"
profile="<AWS_PROFILE>"
```

Crea el `terraform.tfvars`, te puedes inspirar en `terraform.tfvars.example`

```conf
aws_profile="<AWS_PROFILE>"
aws_account_id = "<AWS_ACCOUNT_ID>"
OPENAI_API_KEY="Una key temporal del api de openai que seguramente te la enviare al correo"
AWS_ACCESS_KEY_ID="aws access key del profile"
AWS_ACCESS_KEY_SECRET="secret key del profile"
aws_region = "<AWS_REGION>"
```


#### Porque estas tfvars?

* Mi app hace un llamado al api de OpenAI, `OPENAI_API_KEY` la enviare por correo y la desactivare despues de unos dias, si tienes una key de open_ai que funcione tambien la puedes usar
* `AWS_ACCESS_KEY_ID` y `AWS_ACCESS_KEY_SECRET` las uso para aprovisionar los secretos del agente de codebuild, (se que lo puedo hacer con un rol pero debido a que uso un `AWS_PROFILE` en toda la infra como codigo y no tengo mucho tiempo, de momento lo dejo asi (deuda tecnica))


Despues se debe inicializar el backend s3 (no use lock con dynamodb ya que al trabajar solo no lo vi necesario)

```
terraform init -backend-config=tf_backend.conf
```

Aplicar los dos primeros modulos (`networking` y `eks`), no se aplican los demas porque el provider de kubernetes depende de datos que son salida de module.eks (pues depende de que el cluster exista) y terraform plan intenta inicializar todos los providers al hacer el plan.

El siguiente comando entonces desplegara todos los recursos de red (VPC, Subnets, IGW, NAT, ETC..) y un cluster de EKS con los addons necesarios:

```
terraform apply -target=module.network -target=module.eks
```

Se aplican el resto de recursos, estos incluyen el AWS Load Balancer Controller, las dos aplicaciones y proyecto de codebuild para el CICD.

En el primer despliegue en local se buildearan las imagenes de docker con un local provisioner y se subiran a sus respectivos repositorios de ECR

```
terraform apply
```

k8s_apps: contiene los manifiestos de k8s usando el provider de kubernetes, con un count (if) controlo si se crea ingress o no de esta manera re uso el mismo modulo para crear las dos apps

codebuild: es un modulo para crear el proyecto de codebuild sencillo, el trigger queda siendo manual desde la UI o a traves de AWS CLI, no quice complicar la infra con webhooks de github.

**Puede que los primeros 2 minutos despues del despliegue la ruta no funcione pues el balanceador de carga tarda unos minutos en terminarse de aprovisionar**

**Despues de finalizar el despliegue obtendras un output que es el hostname del ALB:**

```
Outputs:

alb_endpoint = tolist([
  {
    "hostname" = "k8s-default-neatrans-a7b869f0b9-647273833.us-east-1.elb.amazonaws.com"
    "ip" = tostring(null)
    "ports" = tolist(null) /* of object */
  },
])
```


**El cual podras consumir con un post asi:**

E.G.:
```bash
curl --location 'k8s-default-neatrans-a7b869f0b9-647273833.us-east-1.elb.amazonaws.com/traducir/' \
--header 'Content-Type: application/json' \
--data '{
    "mensaje": "Esta conmemoración nos evoca ese patriotismo que motiva a izar la bandera, a ponernos prendas de vestir con los colores patrios y a sentirnos orgullosos de nuestros exponentes culturales y sociales",
    "nivel_de_nea": 10,
    "region": "bogota"
}'
```

Resultado:
```json
{
    "traduccion_nea": "Esta jartera nos recuerda ese amor por el parche que nos motiva a fuequear la bandera, a ponernos las trapas con los colores de la chimba y a sentirnos bacanos de nuestros broders culturales y sociales",
    "mensaje": "Esta conmemoración nos evoca ese patriotismo que motiva a izar la bandera, a ponernos prendas de vestir con los colores patrios y a sentirnos orgullosos de nuestros exponentes culturales y sociales",
    "nivel_de_nea": 10,
    "region": "bogota"
}
```


# Aplicaciones

Es un traductor del español regular al español nea o ñero que llaman, el lenguaje callejero que es diferente en cada region de colombia

Esta compuesto de un API client en FastAPI (`nea-translator`) y un GRPC Server que recibe los llamados de nea-translator por GRPC y envia peticiones a el API de OPENAI para hacer la traduccion (`nea-translator-grpc-server`)

Ambas apps estan hechas con python, pipenv para los ambientes virtuales y dependencias, en cada carpeta hay un par de dockerfiles que sirven como imagen de build y tambien de runtime, tambien hay un `docker-compose.yml`, un `start.sh` y un `startbuild.sh` que
permiten arrancar en local la aplicacion usando `dockercompose` y los secretos que existan en el `.env`

`nea-translator` tiene una prueba unitaria para simular el CI del proceso de CICD

Para arrancar la aplicacion se debe:

* crear un `.env` colocando el valor de OPENAI_API_KEY
* ejecutar `./startbuild.sh`