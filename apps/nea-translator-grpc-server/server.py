from concurrent import futures
import grpc
import nea_translator_pb2
import nea_translator_pb2_grpc
from nea_service.openai_nea_service import translate, promtpter
import json
import os
from dotenv import load_dotenv

load_dotenv()


class NeaTranslatorServicer(nea_translator_pb2_grpc.NeaTranslatorServicer):
    def Translate(self, request, context):
        result=translate(mensaje=request.mensaje, level=request.nivel_de_nea, region=request.region)
        try:
            json_result=json.loads(result)
            json_result=json_result['traduccion']
            print(json_result)
            result_to_send=json_result
        except Exception as e:
            print("Error parsing result", e)
            result_to_send = result
        return nea_translator_pb2.TranslationResponse(traduccion=result_to_send)

def serve():
    port = "50051"
    print(f"Server started, listening on: {port}" )
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    print(f"Server started, listening on: {port}" )
    nea_translator_pb2_grpc.add_NeaTranslatorServicer_to_server(NeaTranslatorServicer(), server)
    server.add_insecure_port(f'[::]:{port}')
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
