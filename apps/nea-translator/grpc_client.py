import grpc
import nea_translator_pb2
import nea_translator_pb2_grpc
import os


GRPC_SERVER=os.environ.get("GRPC_SERVER")

def translate_text(stub, mensaje, nivel_de_nea, region):
    request = nea_translator_pb2.TranslationRequest(
        mensaje=mensaje,
        nivel_de_nea=nivel_de_nea,
        region=region
    )
    response = stub.Translate(request)
    return response.traduccion

def run(mensaje, nivel_de_nea, region):
    with grpc.insecure_channel(GRPC_SERVER) as channel:
        stub = nea_translator_pb2_grpc.NeaTranslatorStub(channel)
        translation = translate_text(stub, mensaje, nivel_de_nea, region)
        return translation
