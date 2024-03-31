from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, constr, conint
from grpc_client import run
import os
APP_VERSION=os.environ.get("APP_VERSION")

class Item(BaseModel):
    mensaje: str
    nivel_de_nea: int = Field(..., ge=1, le=10)
    region: str = Field(pattern='^(medellin|bogota|cali|barranquilla)$')

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Helloxxx, World nea!", "version": APP_VERSION}

@app.post("/traducir/")
def create_item(item: Item):
    traduccion = run(mensaje=item.mensaje, nivel_de_nea=item.nivel_de_nea, region=item.region)
    return { "traduccion_nea": traduccion , "mensaje":item.mensaje, "nivel_de_nea": item.nivel_de_nea, "region": item.region}