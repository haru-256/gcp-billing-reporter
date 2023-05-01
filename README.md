# Billing Reporter

## Google Cloud Architecture

```mermaid
---
title: Billing Reporter
---
flowchart LR
    subgraph Google Cloud
    scheduler["Cloud Scheduler\n run everyday at 7:00"] --> pubsub[Cloud PubSub]
    pubsub --> function[Cloud Function]
    function <-->|fetch cost data| bigquery[BigQuery]
    end
    subgraph Github
    github["Github Action\n Deploy if commit on main branch"] -->|deploy| function
    end
    subgraph Slack
    function -->|post cost message| slack[slack channel]
    end
```


## Directory

```sh
.
├── README.md
├── .github/workflows/
├── src/
└── terraform/
```

- `src`: Source of Billing Reporter, which is written by Python.
- `terraform`: Manage infrastructure,  google cloud, github, terraform cloud. Those are managed by IaC, terraform.
- `.github/workflows`: Github Action. Now, there are Lint-CI and Billing Reporter Deployment which is deployed to Google Cloud.
