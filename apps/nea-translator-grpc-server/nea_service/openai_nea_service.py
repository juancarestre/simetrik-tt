import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY")
)

def translate(mensaje, level, region):
    prompt = promtpter(mensaje, level, region)
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
        model="gpt-3.5-turbo",
    )
    result = chat_completion.choices[0].message.content
    return result



def promtpter(mensaje, level, region):
    try:
        promtp = f"""
        Eres un traductor gracioso de espanol tradicional a lenguaje Nea o callejero de las regiones de colombia
        Quiero que tengas 10 niveles de Nea, siendo 0 nada nea a 10 el maximo de nea
        El mensaje sera traducido del espanol tradicional al nea de la region de colombia: {region} en nivel de nea {level}
        El mensaje a traducir sera: {mensaje}
        Porfavor responde en formato json que solo tenga esta llave y el respectivo valor asi => "traduccion": "<VALORQUETUTRADUJISTE>"
        Solo responde con el json NADA MAS
        """
    except Exception as e:
        promtp=e
    return promtp