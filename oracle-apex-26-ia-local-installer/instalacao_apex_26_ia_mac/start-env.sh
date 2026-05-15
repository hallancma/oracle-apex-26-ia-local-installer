#!/bin/bash
colima start --profile iaapex
docker-compose up -d
echo "✅ Ambiente APEX rodando em http://localhost:8181/ords/apex"
