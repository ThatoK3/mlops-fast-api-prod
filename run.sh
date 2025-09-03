docker compose down
sleep 5s
source .env
docker compose --env-file .env up -d --build

sleep 30s
bash dbz-register-mysql-source.sh

sleep 30s
curl -s http://localhost:8083/connectors/stroke-predictions-connector/status | jq
