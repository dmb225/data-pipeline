# Data Pipeline DevOps on GCP

## 📌 Overview
This is a minimal data pipeline on **Google Cloud**:
- Data is published into **Pub/Sub**
- A **Cloud Function** is triggered
- Processed data is inserted into **Cloud SQL (Postgres)**

We use **Terraform** for Infrastructure as Code (IaC).

## ⚙️ Quick Start

### 1. Create Free GCP Account
- [https://cloud.google.com/free](https://cloud.google.com/free): $300 free credits
- Install SDK: https://cloud.google.com/sdk/docs/install
- Create a new project on https://console.cloud.google.com

### 2. Configure Environment
```bash
gcloud auth application-default login
gcloud config set project <PROJECT_ID>
```
