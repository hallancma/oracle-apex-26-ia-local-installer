#!/bin/bash
docker-compose stop
colima stop --profile iaapex
echo "✅ Ambiente desligado e RAM liberada."
