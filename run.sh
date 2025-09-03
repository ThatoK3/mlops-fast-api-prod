docker compose down
sleep 5s
source .env
docker compose --env-file .env up -d --build

sleep 60s
bash upload_db_data.sh

sleep 30s
bash dbz-register-mysql-source.sh

sleep 30s
curl -s http://localhost:8083/connectors/stroke-predictions-connector/status | jq

sleep 30s
bash mssql-sink-connect.sh

sleep 30s
bash register-s3-sink.sh

sleep 30s
curl -s http://localhost:8083/connectors/


