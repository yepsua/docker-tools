#!/bin/bash

echo "🏁 Inicializando recursos en LocalStack..."

# Crear bucket si no existe
awslocal s3 mb s3://test-bucket || true
