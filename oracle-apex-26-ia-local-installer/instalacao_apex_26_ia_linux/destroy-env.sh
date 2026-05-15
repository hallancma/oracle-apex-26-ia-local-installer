#!/bin/bash
docker-compose stop
docker-compose down -v
rm -rf apex-images ords-config
echo "💥 Ambiente destruído."
