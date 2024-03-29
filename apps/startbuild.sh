#!/bin/bash

# Lee el valor de la variable de entorno desde un archivo (por ejemplo, .env)
export OPENAI_API_KEY=$(cat .env | grep OPENAI_API_KEY | cut -d '=' -f2)

# Ejecuta docker-compose up
docker-compose up --build