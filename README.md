MLOps FastAPI Production Platform
A comprehensive machine learning operations platform for stroke prediction, featuring FastAPI model serving, real-time data streaming with Kafka Connect, and distributed processing with Apache Spark. This production-ready solution provides end-to-end ML pipeline automation with infrastructure-as-code deployment.

🌟 Key Features
Production Model Serving: FastAPI-based REST API for stroke prediction model

Real-time CDC Pipeline: Debezium-powered Change Data Capture with MySQL to MSSQL/S3 streaming

Distributed Processing: Apache Spark cluster with PySpark Jupyter notebooks

Infrastructure Automation: Complete Jenkins pipeline for AWS EC2 provisioning and deployment

Monitoring Integration: Prometheus metrics collection with JMX exporters

Containerized Deployment: Docker Compose for multi-service environment management

Data Persistence: MySQL database for prediction storage and CDC sourcing

🏗️ System Architecture
text
Data Flow:
FastAPI → MySQL → Debezium CDC → Kafka → [MSSQL Sink, S3 Sink, Spark Processing]

Infrastructure:
AWS EC2 → Docker → Multi-Service Container Platform
📊 Data Schema
Input Data Format
The API accepts patient data in the following format:

json
{
  "gender": "Male",
  "age": 60,
  "hypertension": 0,
  "heart_disease": 1,
  "avg_glucose_level": 118.7,
  "bmi": 22.0,
  "smoking_status": "never smoked",
  "name": "Michael White",
  "country": "South Africa",
  "province": "Eastern Cape"
}
Database Schema
Predictions are stored in a MySQL table with the following structure:

sql
CREATE TABLE predictions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    gender VARCHAR(10),
    age FLOAT,
    hypertension TINYINT(1),
    heart_disease TINYINT(1),
    avg_glucose_level FLOAT,
    bmi FLOAT,
    smoking_status VARCHAR(20),
    name VARCHAR(100),
    country VARCHAR(50),
    province VARCHAR(50),
    probability FLOAT,
    risk_category VARCHAR(10),
    contributing_factors JSON,
    prediction_data JSON
)
📦 Container Services Overview
Database Layer
MySQL Container (quay.io/debezium/example-mysql:1.9)

Purpose: Primary relational database for stroke prediction data

Port: 3306 (MySQL protocol)

Features:

Pre-configured for Debezium CDC with binary logging enabled

Health checks using mysqladmin ping

Automatic initialization from SQL scripts in ./init directory

Persistent data storage for production data

Role: Serves as the source database for Change Data Capture

Kafka Ecosystem
Zookeeper Container (confluentinc/cp-zookeeper:5.5.3)

Purpose: Distributed coordination service for Kafka cluster

Port: 2181 (Client connections)

Features:

Manages Kafka broker coordination and leader election

Stores Kafka metadata and configuration

Essential for Kafka cluster stability and failover

Role: Foundation for Kafka distributed system

Kafka Broker Container (confluentinc/cp-enterprise-kafka:5.5.3)

Purpose: Distributed event streaming platform

Ports: 9092 (Kafka protocol), 9991 (JMX monitoring)

Features:

Handles real-time data streaming between connectors

Manages topic partitions and message replication

JMX monitoring enabled for performance metrics

Single broker configuration suitable for development

Role: Central message bus for all data streaming

Kafka Connect Container (quay.io/debezium/connect:1.9)

Purpose: Framework for connecting Kafka with external systems

Ports: 8083 (REST API), 9400 (JMX metrics)

Features:

Debezium implementation for Change Data Capture

REST API for connector management

JMX metrics exposed for Prometheus monitoring

Custom connector JARs mounted for JDBC and S3 sinks

Role: Executes CDC and data sinking operations

Schema Registry Container (confluentinc/cp-schema-registry:5.5.3)

Purpose: Manages Avro schema definitions and evolution

Port: 8081 (HTTP API)

Features:

Stores and manages Avro schemas for Kafka messages

Ensures schema compatibility across services

Provides schema validation and versioning

Role: Schema management for structured data streaming

Application Layer
FastAPI Application Container (Custom built)

Purpose: Machine learning model serving API for stroke prediction

Port: 8000 (HTTP API)

Features:

RESTful API with Logistic Regression model

Automatic feature engineering (age groups, BMI categories, glucose categories)

Database integration for prediction storage

Health checks and model information endpoints

Interactive API documentation (Swagger UI)

Role: Serves machine learning predictions to clients

Data Processing Layer
Spark Master Container (bitnami/spark:3.5.1)

Purpose: Cluster manager for Spark distributed processing

Ports: 7077 (Spark communication), 8080 (Web UI)

Features:

Manages Spark worker nodes and resource allocation

Web UI for cluster monitoring and job management

Simplified configuration for development environment

Role: Coordinates distributed data processing tasks

Spark Worker Container (bitnami/spark:3.5.1)

Purpose: Executes distributed data processing tasks

Features:

Connects to Spark master for task execution

Configurable memory and core allocation

Processes data from Kafka topics or other sources

Role: Performs actual data computation in distributed manner

PySpark Jupyter Container (jupyter/pyspark-notebook:latest)

Purpose: Interactive development environment for data science

Port: 9999 (Jupyter Notebook interface)

Features:

Jupyter Lab with PySpark integration

Pre-configured AWS credentials for S3 access

Mounted volume for persistent notebook storage

Access to Spark cluster for distributed processing

Role: Data exploration, model development, and analysis

📊 Container Network Architecture
text
app-network:
  mysql ↔ zookeeper ↔ kafka ↔ connect ↔ schema-registry ↔ stroke-prediction-api
  
spark-network:
  spark ↔ spark-worker-1 ↔ pyspark
app-network: Connects all primary application services including database, Kafka ecosystem, and API

spark-network: Isolated network for Spark cluster communication and distributed processing

🔄 Data Pipeline Flow
Data Ingestion: API receives patient data via POST requests

Prediction: Logistic Regression model calculates stroke risk probability

Storage: Predictions stored in MySQL database with full context

CDC Capture: Debezium monitors MySQL binary logs for changes

Stream Processing: Changes stream through Kafka topics

Data Sinking:

MSSQL Sink: Real-time replication to MSSQL database

S3 Sink: Archival to AWS S3 bucket in optimized format

Spark Processing: Optional real-time processing with PySpark

🚀 Quick Start
Prerequisites
Docker and Docker Compose

Python 3.8+

AWS Account (for full deployment)

Jenkins (for automated pipeline)

Local Development
bash
# Clone the repository
git clone https://github.com/ThatoK3/mlops-fast-api-prod.git
cd mlops-fast-api-prod

# Create environment file from template
cp .env.example .env
# Edit .env with your database and AWS credentials

# Start all services
docker-compose up -d

# Initialize database
bash upload_db_data.sh

# Access services
# FastAPI: http://localhost:8000
# API Docs: http://localhost:8000/docs
# Jupyter: http://localhost:9999
# Spark UI: http://localhost:8080
# Kafka Connect: http://localhost:8083
Using the Run Script
bash
# Make script executable
chmod +x run.sh

# Execute the application
./run.sh
The run.sh script automatically:

Checks for Python virtual environment

Installs required dependencies

Starts the FastAPI server with uvicorn

Sets appropriate environment variables

🔧 Configuration
Environment Variables
Create a .env file based on the provided template:

ini
# Database Configuration
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_USER=your_mysql_user
MYSQL_PASSWORD=your_mysql_password
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=stroke_predictions

# MSSQL Configuration
MSSQL_HOST=your-mssql-host
MSSQL_PORT=1433
MSSQL_DB=stroke_predictions_sink
MSSQL_USER=your_user
MSSQL_PASSWORD=your_password

# AWS Configuration
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_DEFAULT_REGION=us-east-1
AWS_REGION=us-east-1
S3_BUCKET=mlops-dbz-sink

# Application Paths
JDBC_SINK_JARS=./kconnect-jdbc-sink-jars
S3_SINK_JARS=./kconnect-s3-sink-jars
CONNECT_TRANSFORMS=./confluentic-connect-transforms
FAST_API=./fast_api
MODELS=./models
SAVED_MODEL=./models/Logistic_Regression.pkl
📊 API Endpoints
FastAPI Service (Port 8000)
Endpoint	Method	Description	Example Response
/	GET	Health check endpoint	{"message": "Stroke Prediction API"}
/docs	GET	Interactive API documentation	Swagger UI
/model_info	GET	Get model information and metadata	{"model_type": "LogisticRegression"}
/api/v1/predict	POST	Make stroke prediction with input data	{"probability": 0.45, "risk_category": "Medium", "prediction_id": 123}
/predictions	GET	Retrieve recent predictions	List of prediction records
Example API Request
bash
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "gender": "Male",
    "age": 60,
    "hypertension": 0,
    "heart_disease": 1,
    "avg_glucose_level": 118.7,
    "bmi": 22.0,
    "smoking_status": "never smoked",
    "name": "Michael White",
    "country": "South Africa",
    "province": "Eastern Cape"
  }'
Example Response
json
{
  "probability": 0.45,
  "risk_category": "Medium",
  "contributing_factors": ["age", "avg_glucose_level", "bmi"],
  "prediction_id": 123
}
🔄 Data Pipeline Setup
Connector Configuration Scripts
The platform includes automated scripts for connector configuration:

bash
# Register MySQL source connector (Debezium CDC)
bash dbz-register-mysql-source.sh

# Register MSSQL sink connector  
bash dbz-register-mssql-sink.sh

# Register S3 sink connector
bash dbz-register-s3-sink.sh
Connector Functions
MySQL Source Connector: Captures changes from MySQL predictions table

MSSQL Sink Connector: Replicates data to MSSQL for reporting and analytics

S3 Sink Connector: Archives data to S3 for long-term storage and batch processing

📈 Monitoring & Metrics
Available Endpoints
Service	Port	Endpoint	Purpose
FastAPI	8000	/	Health check
FastAPI	8000	/docs	API documentation
Kafka Connect	8083	/connectors	Connector management
JMX Metrics	9400	/metrics	Prometheus metrics
Spark Master	8080	/	Spark cluster UI
Jupyter	9999	/	Notebook interface
Prometheus Integration
The JMX exporter configuration in jmx_exporter/config.yaml enables monitoring of:

Kafka Connect metrics and performance

JVM performance indicators and garbage collection

Connector status, throughput, and error rates

System resource utilization

🚀 Production Deployment
Jenkins Pipeline
The Jenkinsfile defines a complete CI/CD pipeline that:

Infrastructure Provisioning: Creates EC2 instances with proper networking

Environment Setup: Installs Docker, dependencies, and monitoring tools

Service Deployment: Uses Docker Compose for multi-service deployment

Data Pipeline Setup: Configures Kafka Connect connectors

Monitoring Configuration: Sets up Prometheus for metrics collection

Validation: Runs health checks and service validation

AWS Requirements
VPC with appropriate subnets in us-east-1

EC2 launch template and AMI configured for Docker

RDS MSSQL instance for data sinking

S3 bucket for data archival

Proper security groups and IAM roles

Jenkins Credentials
The pipeline requires these Jenkins credentials:

aws-jenkins-creds: AWS access credentials

mlops-ssh-key: EC2 SSH private key

Database credentials for MySQL and MSSQL

🛠️ Development Guide
Model Management
Place model files in models/ directory

Update model loading in app/core/model.py

Ensure feature engineering matches training pipeline

Adding New Features
Update the PatientData Pydantic model in main.py

Add corresponding feature engineering logic

Test with sample data to ensure compatibility

Database Schema Changes
Update init/init.sql with schema changes

Modify upload_db_data.sh if needed

Test database initialization process

🚨 Troubleshooting
Common Issues
Database Connection Failures

Verify credentials in .env file

Check if MySQL container is running: docker-compose ps mysql

Examine logs: docker-compose logs mysql

Kafka Connect Errors

Check connector status: curl http://localhost:8083/connectors/

Examine connect logs: docker-compose logs connect

Verify network connectivity between services

API Deployment Issues

Check FastAPI logs: docker-compose logs stroke-prediction-api

Verify model file exists: ls models/Logistic_Regression.pkl

Test API health: curl http://localhost:8000/

Logs and Debugging
bash
# View service logs
docker-compose logs [service_name]

# Follow logs in real-time
docker-compose logs -f [service_name]

# Check service status
docker-compose ps

# Access running containers
docker-compose exec [service_name] bash

# Monitor Kafka topics
docker-compose exec kafka kafka-topics --list --bootstrap-server kafka:9092
🤝 Contributing
Fork the repository

Create a feature branch (git checkout -b feature/amazing-feature)

Commit changes (git commit -m 'Add amazing feature')

Push to branch (git push origin feature/amazing-feature)

Open a Pull Request

Development Guidelines
Follow existing code style and patterns

Verify Docker Compose still works correctly

Test the Jenkins pipeline if making infrastructure changes

Update documentation for new features

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

🆘 Support
For support and questions:

Check the troubleshooting section above

Review service logs using docker-compose logs

Verify environment variable configuration

Ensure all prerequisite services are running

Examine the Jenkins pipeline output for deployment issues

🔗 Related Projects
MLOps FastAPI Dev & Test: Development and testing repository

Grafana Prometheus Monitoring: Monitoring infrastructure

MLOps Main Repository: Main project repository
