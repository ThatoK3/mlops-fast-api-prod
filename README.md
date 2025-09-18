MLOps FastAPI Srtoke Prediction Production Platform Project
🏗️ System Architecture Overview
text
Data Flow:
FastAPI → MySQL → Debezium CDC → Kafka → [MSSQL Sink, S3 Sink, Spark Processing]

Container Network:
app-network: mysql ↔ zookeeper ↔ kafka ↔ connect ↔ schema-registry ↔ stroke-prediction-api
spark-network: spark ↔ spark-worker-1 ↔ pyspark
📦 Container Services Detailed Breakdown
Database Layer
MySQL Container (quay.io/debezium/example-mysql:1.9)

text
┌─────────────────────────────────────────────────┐
│                   MySQL                         │
│                                                 │
│  Port: 3306                                     │
│  Role: Primary data store with CDC enabled      │
│  Features:                                      │
│    - Pre-configured for Debezium CDC            │
│    - Automatic schema initialization            │
│    - Health monitoring                          │
│    - Persistent storage                         │
└─────────────────────────────────────────────────┘
Purpose: Primary relational database for stroke prediction data

Port: 3306 (MySQL protocol)

Features: Pre-configured for Debezium CDC with binary logging, health checks, automatic initialization

Role: Serves as the source database for Change Data Capture

Kafka Ecosystem
Zookeeper Container (confluentinc/cp-zookeeper:5.5.3)

text
┌─────────────────────────────────────────────────┐
│                 Zookeeper                       │
│                                                 │
│  Port: 2181                                     │
│  Role: Cluster coordination service             │
│  Features:                                      │
│    - Manages Kafka broker coordination          │
│    - Stores metadata and configuration          │
│    - Essential for cluster stability            │
└─────────────────────────────────────────────────┘
Purpose: Distributed coordination service for Kafka cluster

Port: 2181 (Client connections)

Role: Foundation for Kafka distributed system

Kafka Broker Container (confluentinc/cp-enterprise-kafka:5.5.3)

text
┌─────────────────────────────────────────────────┐
│                   Kafka                         │
│                                                 │
│  Ports: 9092, 9991 (JMX)                       │
│  Role: Distributed event streaming platform     │
│  Features:                                      │
│    - Real-time data streaming                   │
│    - Topic partitions management                │
│    - Message replication                        │
│    - JMX monitoring                             │
└─────────────────────────────────────────────────┘
Purpose: Distributed event streaming platform

Ports: 9092 (Kafka protocol), 9991 (JMX monitoring)

Role: Central message bus for all data streaming

Kafka Connect Container (quay.io/debezium/connect:1.9)

text
┌─────────────────────────────────────────────────┐
│               Kafka Connect                     │
│                                                 │
│  Ports: 8083 (REST), 9400 (JMX)                │
│  Role: CDC and data integration framework       │
│  Features:                                      │
│    - Debezium CDC implementation                │
│    - REST API for management                    │
│    - JMX metrics for monitoring                 │
│    - Custom connector support                   │
└─────────────────────────────────────────────────┘
Purpose: Framework for connecting Kafka with external systems

Ports: 8083 (REST API), 9400 (JMX metrics)

Role: Executes CDC and data sinking operations

Schema Registry Container (confluentinc/cp-schema-registry:5.5.3)

text
┌─────────────────────────────────────────────────┐
│              Schema Registry                    │
│                                                 │
│  Port: 8081                                     │
│  Role: Avro schema management                   │
│  Features:                                      │
│    - Schema storage and versioning              │
│    - Schema validation                          │
│    - Compatibility checking                     │
└─────────────────────────────────────────────────┘
Purpose: Manages Avro schema definitions and evolution

Port: 8081 (HTTP API)

Role: Schema management for structured data streaming

Application Layer
FastAPI Application Container (Custom built)

text
┌─────────────────────────────────────────────────┐
│               FastAPI Service                   │
│                                                 │
│  Port: 8000                                     │
│  Role: ML model serving API                     │
│  Features:                                      │
│    - Stroke prediction model                    │
│    - Automatic feature engineering              │
│    - Database integration                       │
│    - Interactive documentation                  │
└─────────────────────────────────────────────────┘
Purpose: Machine learning model serving API for stroke prediction

Port: 8000 (HTTP API)

Features: RESTful API with Logistic Regression model, automatic feature engineering, database integration

Role: Serves machine learning predictions to clients

Data Processing Layer
Spark Master Container (bitnami/spark:3.5.1)

text
┌─────────────────────────────────────────────────┐
│               Spark Master                      │
│                                                 │
│  Ports: 7077, 8080 (Web UI)                    │
│  Role: Cluster manager for Spark                │
│  Features:                                      │
│    - Resource allocation                        │
│    - Job scheduling                             │
│    - Web UI for monitoring                      │
└─────────────────────────────────────────────────┘
Purpose: Cluster manager for Spark distributed processing

Ports: 7077 (Spark communication), 8080 (Web UI)

Role: Coordinates distributed data processing tasks

Spark Worker Container (bitnami/spark:3.5.1)

text
┌─────────────────────────────────────────────────┐
│               Spark Worker                      │
│                                                 │
│  Role: Distributed task execution               │
│  Features:                                      │
│    - Executes Spark tasks                       │
│    - Configurable resources                     │
│    - Fault tolerance                            │
└─────────────────────────────────────────────────┘
Purpose: Executes distributed data processing tasks

Role: Performs actual data computation in distributed manner

PySpark Jupyter Container (jupyter/pyspark-notebook:latest)

text
┌─────────────────────────────────────────────────┐
│               Jupyter Notebook                  │
│                                                 │
│  Port: 9999                                     │
│  Role: Interactive data science environment     │
│  Features:                                      │
│    - PySpark integration                        │
│    - AWS S3 access                              │
│    - Persistent notebook storage                │
│    - Spark cluster access                       │
└─────────────────────────────────────────────────┘
Purpose: Interactive development environment for data science

Port: 9999 (Jupyter Notebook interface)

Role: Data exploration, model development, and analysis

🔄 Data Pipeline Flow
text
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   FastAPI   │    │    MySQL    │    │   Debezium  │    │    Kafka    │
│             │    │             │    │             │    │             │
│  Port 8000  │───▶│  Port 3306  │───▶│  Port 8083  │───▶│  Port 9092  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                   │
                                                                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    S3 Sink  │    │ MSSQL Sink  │    │   Spark     │    │  Jupyter    │
│             │    │             │    │             │    │             │
│  AWS S3     │◀───│  MSSQL DB   │◀───│ Processing  │◀───│  Port 9999  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
Data Ingestion: API receives patient data via POST requests

Prediction: Logistic Regression model calculates stroke risk probability

Storage: Predictions stored in MySQL database with full context

CDC Capture: Debezium monitors MySQL binary logs for changes

Stream Processing: Changes stream through Kafka topics

Data Sinking:

MSSQL Sink: Real-time replication to MSSQL database

S3 Sink: Archival to AWS S3 bucket in optimized format

Spark Processing: Optional real-time processing with PySpark

🚀 Deployment Method: Jenkins Pipeline
This platform uses a sophisticated Jenkins pipeline for automated deployment rather than local execution scripts. The pipeline handles complete infrastructure provisioning, service deployment, and monitoring setup.

Pipeline Overview
The Jenkins pipeline automates the following stages:

Infrastructure Provisioning: EC2 instance creation with proper networking

Environment Setup: Docker installation and dependency management

Service Deployment: Multi-container deployment with Docker Compose

Data Pipeline Setup: Kafka Connect connector configuration

Monitoring Configuration: Prometheus and metrics setup

Validation: Comprehensive health checks and service validation

📋 Prerequisites
AWS Infrastructure Requirements
VPC with appropriate subnets in us-east-1

EC2 launch template (lt-0b64c4af9d5f19bd8)

AMI configured for Docker (ami-020cba7c55df1f615)

RDS MSSQL instance for data sinking

S3 bucket (mlops-dbz-sink) for data archival

Proper security groups and IAM roles

Jenkins Configuration
The pipeline requires these Jenkins credentials:

aws-jenkins-creds: AWS access credentials

mlops-ssh-key: EC2 SSH private key

mlflow-experiments-db-creds: MySQL user credentials

mlflow-experiments-db-root-user-creds: MySQL root credentials

aws-mssql-db-stroke-pred-api-v1: MSSQL database credentials

📊 API Endpoints
Endpoint	Method	Description
/	GET	Health check endpoint
/docs	GET	Interactive API documentation
/model_info	GET	Get model information and metadata
/predict	POST	Make stroke prediction with input data
/predictions	GET	Retrieve recent predictions
🔍 Monitoring & Metrics
Available Endpoints
Service	Port	Endpoint	Purpose
FastAPI	8000	/	Health check
FastAPI	8000	/docs	API documentation
Kafka Connect	8083	/connectors	Connector management
JMX Metrics	9400	/metrics	Prometheus metrics
Spark Master	8080	/	Spark cluster UI
🛠️ Maintenance and Operations
Checking Service Status
bash
# View container logs
docker-compose logs [service_name]

# Check service status
docker-compose ps

# Monitor Kafka topics
docker-compose exec kafka kafka-topics --list --bootstrap-server kafka:9092
Connector Management
bash
# List connectors
curl http://localhost:8083/connectors/

# Check connector status
curl http://localhost:8083/connectors/[connector_name]/status

# Restart connector
curl -X POST http://localhost:8083/connectors/[connector_name]/restart
🚨 Troubleshooting
Common Issues
Database Connection Failures

Verify credentials in environment variables

Check MySQL container status

Examine database connection logs

Kafka Connect Errors

Check connector status via REST API

Examine connect logs for specific errors

Verify network connectivity between services

API Deployment Issues

Check FastAPI logs for model loading errors

Verify model file exists in correct location

Test API health endpoint

📈 Performance Monitoring
The platform includes comprehensive monitoring through:

Prometheus metrics collection

JMX exporters for JVM monitoring

Node exporters for system metrics

Kafka Connect metrics for pipeline performance

🔗 Related Projects
MLOps FastAPI Dev & Test: Development and testing repository

Grafana Prometheus Monitoring: Monitoring infrastructure

MLOps Main Repository: Main project repository

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

🆘 Support
For support and deployment issues:

Check the Jenkins pipeline output for specific errors

Review service logs using Docker commands

Verify AWS credential configuration in Jenkins

Ensure all prerequisite resources are properly configured

Note: This is a production-grade MLOps platform designed for automated deployment through Jenkins. Manual execution is not recommended for production environments. Ensure proper security measures, monitoring, and backup strategies are in place before deployment.
