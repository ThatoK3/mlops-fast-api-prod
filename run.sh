docker compose down
sleep 5s
source .env
docker compose --env-file .env up -d --build
