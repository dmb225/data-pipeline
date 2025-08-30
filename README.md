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
- Enable APIs for your project: Cloud Functions, Artifact Registry, Cloud Build, Cloud SQL Admin

### 2. Configure Environment
```bash
gcloud auth application-default login
gcloud config set project <PROJECT_ID>
```

## Workflow

### Description
The data pipeline follows this sequence:

1. **Source Data**
   - Data is generated or sent from your application.
   - Messages must be in JSON format, e.g. `{"id": 1, "value": "hello"}`.

2. **Publish to Pub/Sub**
   - The data is sent to the **Pub/Sub topic** created by Terraform
   - Pub/Sub ensures reliable delivery and buffering of messages.

3. **Cloud Function Triggered**
   - Each message published to Pub/Sub triggers the Cloud Function.
   - The function receives the event payload and processes the message.

4. **Process and Store in Cloud SQL**
   - The Cloud Function connects to the **Cloud SQL Postgres database** using the credentials defined in Terraform.
   - Creates the table if it does not exist (`processed_data`).
   - Inserts the processed record (e.g., converting values to uppercase).

5. **Verification**
   - After publishing messages, you can connect to the Cloud SQL database and query the `processed_data` table to verify successful inserts.

6. **Optional: Cleanup**
   - Run `terraform destroy` to remove all resources and avoid charges.

### Commands

#### Package the Cloud Function
```
cd cloud_function
zip -r function-source.zip .
cd ../terraform
```

#### Deploy Infrastructure with Terraform
```
terraform init
terraform apply
```

#### Publish a test Message to Pub/Sub
```
gcloud pubsub topics publish dummy-topic --message '{"id":1,"value":"hello"}'
gcloud pubsub subscriptions create dummy-sub --topic=dummy-topic
gcloud pubsub subscriptions pull dummy-sub --limit=10 --auto-ack
┌──────────────────────────┬───────────────────┬──────────────┬────────────┬──────────────────┬────────────┐
│           DATA           │     MESSAGE_ID    │ ORDERING_KEY │ ATTRIBUTES │ DELIVERY_ATTEMPT │ ACK_STATUS │
├──────────────────────────┼───────────────────┼──────────────┼────────────┼──────────────────┼────────────┤
│ {"id":1,"value":"hello"} │ 15987200681187818 │              │            │                  │ SUCCESS    │
└──────────────────────────┴───────────────────┴──────────────┴────────────┴──────────────────┴────────────┘
```

#### Check cloud function logs
```
gcloud functions logs read pubsub-to-sql --region=<your_region> --limit=10
```

#### Connect to Cloud SQL to verify data
```
gcloud sql connect data-pipeline-sql --user=<db_username>
# This command fails beecause second Generation Cloud SQL instances don’t support IPv6

# Solution 1: Use psql
gcloud sql instances list
psql "host=<PRIMARY_ADDRESS> dbname=<db_name> user=<db_username> password=<db_password> sslmode=require"

# Solution 2: Use gcloud beta
gcloud beta sql connect data-pipeline-sql --user=<db_username> --quiet
```

Then:
```sql
SELECT * FROM processed_data;
```

#### Optional: Cleanup Resources
```
terraform destroy
```
