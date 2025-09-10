#!/bin/bash
set -e
export $(grep -v '^#' .env | xargs)
mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${INSTANCE_PRIVATE_IP} stroke_predictions < stroke_predictions.sql
