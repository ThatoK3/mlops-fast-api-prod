Stroke Prediction API with MLOps Pipeline
A comprehensive MLOps pipeline for stroke prediction using FastAPI, Kafka, Debezium, MySQL, and Spark for real-time data processing and machine learning.

🏗️ Architecture
text
Data Source → MySQL → Debezium CDC → Kafka → Spark Streaming → FastAPI → Prediction Results
📦 Services Included
FastAPI: REST API for stroke predictions

MySQL: Database with patient data

Kafka: Message broker for real-time data streaming

Debezium: Change Data Capture (CDC) for MySQL

Schema Registry: Avro schema management

Spark Cluster: Distributed data processing

PySpark Notebook: Jupyter environment for data analysis

🚀 Quick Start
Prerequisites
Docker and Docker Compose

Python 3.9+

AWS credentials (for S3 integration)

Installation
Clone the repository

bash
git clone https://github.com/ThatoK3/mlops-fast-api-prod.git
cd mlops-fast-api-prod
Set up environment variables

bash
cp .env.example .env
# Edit .env with your actual values
Start all services

bash
docker-compose up -d --build
Verify services are running

bash
docker-compose ps
🔧 Configuration
Environment Variables
Create a .env file with the following variables:

env
# MySQL Configuration
MYSQL_ROOT_PASSWORD=debezium
MYSQL_USER=mysqluser
MYSQL_PASSWORD=mysqlpw
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DB_NAME=stroke_predictions

# AWS Credentials
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=us-east-1

# Paths
JDBC_SINK_JARS=./kconnect-jdbc-sink-jars
S3_SINK_JARS=./kconnect-s3-sink-jars
CONNECT_TRANSFORMS=./confluentic-connect-transforms
FAST_API=./fast_api
MODELS=./models
NOTEBOOKS=./notebooks
Service Ports
FastAPI: http://localhost:8000

MySQL: localhost:3306

Kafka: localhost:9092

Schema Registry: http://localhost:8081

Kafka Connect: http://localhost:8083

Spark UI: http://localhost:8080

Jupyter Notebook: http://localhost:9999

📊 API Usage
Make a Prediction
bash
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "age": 67,
    "hypertension": 0,
    "heart_disease": 1,
    "avg_glucose_level": 228.69,
    "bmi": 36.6,
    "gender": "Male",
    "ever_married": "Yes",
    "work_type": "Private",
    "residence_type": "Urban",
    "smoking_status": "formerly smoked"
  }'
Example Response
json
{
  "prediction": 1,
  "probability": 0.87,
  "stroke_risk": "high"
}
🔄 Data Flow
Data Ingestion: Patient data stored in MySQL

CDC Capture: Debezium captures database changes

Stream Processing: Kafka streams changes to Spark

Model Serving: FastAPI serves predictions using trained model

Monitoring: Spark processes data for analytics

📁 Project Structure
text
├── docker-compose.yml          # Multi-container setup
├── Dockerfile                  # FastAPI container build
├── .env                        # Environment variables
├── fast_api/
│   └── main.py                 # FastAPI application
├── models/
│   └── Logistic_Regression.pkl # Trained model
├── notebooks/                  # Jupyter notebooks
├── kconnect-jdbc-sink-jars/    # JDBC connector jars
├── kconnect-s3-sink-jars/      # S3 connector jars
└── confluentic-connect-transforms/ # Kafka connect transforms
🛠️ Management Commands
Start services
bash
docker-compose up -d
Stop services
bash
docker-compose down
View logs
bash
docker-compose logs -f stroke-prediction-api
Rebuild specific service
bash
docker-compose up -d --build stroke-prediction-api
Access services
bash
# FastAPI docs
open http://localhost:8000/docs

# Jupyter notebook
open http://localhost:9999

# Spark UI
open http://localhost:8080

# Schema Registry
open http://localhost:8081
🤝 Contributing
Fork the repository

Create a feature branch

Make your changes

Add tests if applicable

Submit a pull request

📝 License
This project is licensed under the MIT License - see the LICENSE file for details.

🆘 Troubleshooting
Common Issues
Port conflicts: Ensure ports 8000, 9092, 8080-8083, 9999 are available

Container naming conflicts: Use docker-compose down before starting

Missing model file: Ensure Logistic_Regression.pkl is in ./models/

AWS credentials: Verify AWS keys in .env file

Logs and Debugging
bash
# Check container status
docker-compose ps

# View logs for specific service
docker-compose logs <service-name>

# Shell into container
docker-compose exec stroke-prediction-api bash

Open an issue in the GitHub repository

Note: This setup is for development purposes. For production deployment, consider adding security measures, monitoring, and scaling configurations.
