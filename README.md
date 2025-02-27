<hr>

<div align="center">

<!-- ![](https://uri-to-your-logo-image) -->

<h1 align="center">Continuous Deployment Starter Kit for SLIM</h1>

</div>

<pre align="center">Automated, secure, and efficient continuous deployment for SLIM projects.</pre>

[![SLIM](https://img.shields.io/badge/Best%20Practices%20from-SLIM-blue)](https://nasa-ammos.github.io/slim/)

## Overview
This repository provides a complete Continuous Deployment (CD) starter kit for SLIM projects, enabling automated, efficient, and secure deployments. It follows best practices for CI/CD workflows, environment management, security, and rollback strategies.

## Features
- Automated CI/CD pipeline using GitHub Actions.
- Secure environment variable management.
- Zero-downtime deployment with blue/green and canary strategies.
- Multi-environment support for testing and validation.
- Integrated security scanning and compliance checks.
- Infrastructure as Code (IaC) using Terraform and Kubernetes.

## Contents
* [Quick Start](#quick-start)
* [Changelog](#changelog)
* [FAQ](#frequently-asked-questions-faq)
* [Contributing Guide](#contributing)
* [License](#license)
* [Support](#support)

## Quick Start
This guide provides a quick way to get started with our project. Please see our [docs](https://nasa-ammos.github.io/slim/) for a more comprehensive overview.

### Requirements
* Terraform
* AWS CLI / Kubernetes CLI (kubectl)
* GitHub Actions enabled
* Docker for containerized deployments

### Setup Instructions
1. Clone the Repository
```bash
git clone https://github.com/NASA-AMMOS/slim-cd-starterkit.git
cd slim-cd-starterkit
```
2. Set Up Environment Variables
Use AWS Systems Manager (SSM), HashiCorp Vault, or Kubernetes Secrets for managing secrets securely.
```bash
export DATABASE_URL="your-database-url"
export SECRET_KEY="your-secret-key"
```
3. Deploy Infrastructure
Use Terraform for managing cloud resources:
```bash
cd infra
terraform init
terraform apply -auto-approve
```
4. Run CI/CD Pipeline
Ensure your code passes tests before deployment.
```bash
git push origin main
```
GitHub Actions will automatically:
- Run tests (unit, integration, security checks).
- Build and package the application.
- Deploy to the staging environment.

5. Promote to Production
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## CI/CD Pipeline
```yaml
name: Deploy to Staging
on:
  push:
    branches:
      - main
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
      - name: Install Dependencies
        run: npm install
      - name: Run Tests
        run: npm test
  deploy:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - name: Deploy to Staging
        run: ./deploy.sh staging
```

## Security & Compliance
This section outlines the security practices for ensuring robust and secure deployments.
[OWASP ZAP](https://owasp.org/www-project-zap/) for security scanning.
- Enforce RBAC for cloud resources.
- Regularly audit deployment logs.
- Encrypt sensitive data in transit and at rest.

### Implementing Role-Based Access Control (RBAC)
RBAC restricts access based on user roles, ensuring secure interactions within the system.
#### Example RBAC Policy for AWS IAM:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::example-bucket/*"
    }
  ]
}
```

#### Kubernetes RBAC Example:
RBAC restricts access based on user roles, enhancing security.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create", "update", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: default
subjects:
- kind: User
  name: developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

### Encrypting Sensitive Data
Encryption protects sensitive data both in transit and at rest, ensuring compliance and security best practices.

#### Example: Encrypting Data in AWS S3
```bash
aws s3 cp myfile.txt s3://my-secure-bucket/ --sse AES256
```

#### Encrypting Environment Variables using AWS KMS:
To protect sensitive data, always encrypt in transit and at rest.
#### Encrypting Environment Variables using AWS KMS:
```bash
# Encrypt a value using AWS KMS
aws kms encrypt --key-id alias/my-key --plaintext "my-secret-value" --output text --query CiphertextBlob > secret.enc

# Decrypt the value when needed
aws kms decrypt --ciphertext-blob fileb://secret.enc --output text --query Plaintext | base64 --decode
```

#### Encrypting Data at Rest in PostgreSQL:
```sql
CREATE EXTENSION pgcrypto;
INSERT INTO users (id, email, password) VALUES (1, 'user@example.com', crypt('my-password', gen_salt('bf')));
```
[OWASP ZAP](https://owasp.org/www-project-zap/) for security scanning.
- Enforce RBAC for cloud resources.
- Regularly audit deployment logs.
- Encrypt sensitive data in transit and at rest.


### Security Scanning with OWASP ZAP
OWASP ZAP performs automated penetration testing.
#### Usage:
```bash
# Start OWASP ZAP in daemon mode
zap.sh -daemon -port 8080 &

# Run an automated scan against the target app
zap-cli quick-scan --self-contained http://your-app-url.com
```

- Use[OWASP ZAP](https://owasp.org/www-project-zap/) for security scanning.
- Enforce RBAC for cloud resources.
- Regularly audit deployment logs.
- Encrypt sensitive data in transit and at rest.

## Rollback Strategy
Rollback strategies ensure smooth recovery in case of failed deployments.

- Maintain versioned deployment artifacts.
- Use feature flags for gradual rollouts.
- Implement automated rollback mechanisms using deployment history.
                 
### Example: Kubernetes Rollback
Kubernetes provides a built-in mechanism to rollback a deployment to its previous version.
```bash
kubectl rollout undo deployment/my-app-deployment
```

### Example: Rolling Back in GitHub Actions
Using GitHub Actions to rollback to the last successful deployment.
```yaml
name: Rollback
on:
  workflow_dispatch:

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
      - name: Rollback Deployment
        run: kubectl rollout undo deployment/my-app-deployment
```

### Example: Rolling Back a Docker Deployment
If using Docker, rollback can be done by redeploying the last stable container image.
```bash
docker service update --image my-app:previous-version my-app-service
```


## Monitoring & Logging
Effective monitoring and logging ensure system health and rapid issue resolution.

- Integrate Prometheus, Grafana, and ELK Stack for observability.
- Set up alerts for deployment failures.
- Use centralized logging for debugging and analysis.
  
### Example: Configuring Prometheus & Grafana
#### Deploying Prometheus for Metrics Collection
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-monitor
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: web
    interval: 30s
```

#### Setting Up Grafana Dashboards
```bash
grafana-cli plugins install grafana-piechart-panel
systemctl restart grafana-server
```

### Example: Logging with ELK Stack
#### Configuring Filebeat to Send Logs to Elasticsearch
```yaml
filebeat.inputs:
- type: log
  paths:
    - /var/log/*.log
output.elasticsearch:
  hosts: ["http://elasticsearch:9200"]
```



## Changelog
See our [CHANGELOG.md](CHANGELOG.md) for a history of our changes.

## Frequently Asked Questions (FAQ)
[Questions about our project? Please see our FAQ](https://nasa-ammos.github.io/slim/faq).

## Contributing
1. Fork the repo.
2. Create a feature branch.
3. Submit a PR with your changes.

For guidance on our governance approach, see our [GOVERNANCE.md](GOVERNANCE.md).

## License
See our: [LICENSE](LICENSE)

## Support
For questions, reach out to [@yunks128](https://github.com/yunks128) or the maintainers listed in the repo.
