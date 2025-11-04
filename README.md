# common-protos
Para instalar protos

```bash
poetry run python -m grpc_tools.protoc -I protos --python_out=./protos --grpc_python_out=./protos protos/auth/auth.proto
```