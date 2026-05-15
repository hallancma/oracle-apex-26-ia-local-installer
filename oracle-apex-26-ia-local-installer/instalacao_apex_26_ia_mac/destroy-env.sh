#!/bin/bash
docker-compose stop
docker-compose down -v
colima delete --profile iaapex -f
rm -rf apex-images ords-config
echo "💥 Ambiente destruído."
