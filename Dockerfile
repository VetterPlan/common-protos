# Dockerfile para generar y empaquetar archivos Python desde .proto
FROM python:3.11-slim AS builder

# Instalar dependencias necesarias para compilar protos
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Instalar herramientas de gRPC y protobuf para Python
RUN pip install --no-cache-dir grpcio-tools==1.76.0 protobuf==6.33.0

# Configurar directorio de trabajo
WORKDIR /protos

# Copiar archivos .proto
COPY auth/*.proto ./auth/

# Crear __init__.py si no existe
RUN touch ./auth/__init__.py 2>/dev/null || true
RUN touch ./__init__.py 2>/dev/null || true

# Generar archivos Python desde los .proto
RUN python -m grpc_tools.protoc \
    -I. \
    --python_out=. \
    --grpc_python_out=. \
    auth/auth.proto

# Etapa final: imagen ligera solo con los archivos generados
FROM scratch AS export

COPY --from=builder /protos/auth/*.py /auth/
COPY --from=builder /protos/__init__.py / 2>/dev/null || true

# Etapa para imagen final que puede ser usada como base o para copiar archivos
FROM python:3.11-slim

WORKDIR /protos

# Copiar archivos generados desde builder
COPY --from=builder /protos/ ./

# Esta imagen contiene los archivos generados listos para usar
CMD ["ls", "-la", "/protos"]

