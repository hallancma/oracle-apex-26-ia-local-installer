@echo off
echo ATENCAO: Apagando banco de dados...
docker-compose stop
docker-compose down -v
rmdir /S /Q apex-images
rmdir /S /Q ords-config
echo Ambiente destruido.
pause
