<div align="center">

<!-- ![CD Starter Kit Logo](https://your-logo-url.com) -->

# Continuous Deployment Starter Kit

</div>

<p align="center">Enterprise-grade continuous deployment framework for automated, secure, and efficient software delivery</p>

<p align="center">
  <a href="https://nasa-ammos.github.io/slim/"><img src="https://img.shields.io/badge/Best%20Practices%20from-SLIM-blue" alt="SLIM"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg" alt="License"></a>
</p>

## 📋 Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Security & Compliance](#-security--compliance)
- [Rollback Strategy](#-rollback-strategy)
- [Monitoring & Logging](#-monitoring--logging)
- [Documentation](#-documentation)
- [Changelog](#-changelog)
- [FAQ](#-frequently-asked-questions)
- [Contributing](#-contributing)
- [License](#-license)
- [Support](#-support)

## 🔍 Overview

The Continuous Deployment Starter Kit provides a comprehensive framework for implementing robust, secure, and efficient software delivery pipelines across multiple environments. Built on DevOps best practices and industry standards, this kit streamlines the deployment process while enforcing security controls and operational visibility.

This repository serves as both a reference implementation and a starting point for your own CD workflows, providing ready-to-use templates, infrastructure configurations, and security policies.

## ✨ Key Features

- **Fully Automated Pipelines** — Trigger deployments automatically from code changes with comprehensive testing
- **Multi-Environment Support** — Distinct configurations for development, staging, and production environments
- **Zero-Downtime Deployments** — Blue/green and canary deployment strategies for uninterrupted service
- **Security-First Design** — Built-in security scans, secret management, and compliance checks
- **Infrastructure as Code** — Declarative infrastructure definitions using Terraform and Kubernetes
- **Observability** — Integrated monitoring, alerting, and logging for operational visibility
- **Resilient Operations** — Automated rollback mechanisms and failure recovery procedures

## 🏗 Architecture

```
├── .github/workflows    # CI/CD pipeline definitions
├── infra/               # Infrastructure as Code templates
│   ├── terraform/       # Cloud resource definitions
│   └── kubernetes/      # Kubernetes manifests
├── scripts/             # Deployment and utility scripts
├── monitoring/          # Monitoring and observability configs
└── docs/                # Documentation and guides
```

## 🚀 Quick Start

### Prerequisites

- **Developer Tools**
  - Git
  - Docker Desktop
  - Terraform v1.0+
  - AWS CLI v2 / Kubernetes CLI (kubectl)
  
- **Cloud Access**
  - AWS account with appropriate permissions
  - GitHub repository with Actions enabled
  
- **CI/CD Systems**
  - GitHub account with repository access
  - Docker Hub account (or another container registry)

### Setup Instructions

#### 1. Clone the Repository

```bash
git clone https://github.com/NASA-AMMOS/slim-cd-starterkit.git
cd slim-cd-starterkit
```

#### 2. Configure Secrets and Environment Variables

We recommend using a secure secret management solution such as AWS Systems Manager Parameter Store.

```bash
# Example using AWS SSM
aws ssm put-parameter \
    --name "/myapp/DATABASE_URL" \
    --value "postgresql://user:password@host:port/db" \
    --type "SecureString"

aws ssm put-parameter \
    --name "/myapp/SECRET_KEY" \
    --value "your-secret-key" \
    --type "SecureString"
```

#### 3. Deploy Infrastructure

```bash
cd infra/terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

#### 4. Trigger Your First Deployment

```bash
# Make changes and commit
git add .
git commit -m "Initial deployment"
git push origin main
```

The GitHub Actions workflow will automatically:
- Run unit and integration tests
- Perform security scans
- Build and package the application
- Deploy to the staging environment

#### 5. Promote to Production

```bash
# Create a release tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## 🔄 CI/CD Pipeline

Our pipeline automates the entire deployment process from code changes to production release:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  release:
    types: [published]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
      
      - name: Setup Environment
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Run Linter
        run: npm run lint
      
      - name: Run Unit Tests
        run: npm test
      
      - name: Run Integration Tests
        run: npm run test:integration
        
      - name: Security Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          format: 'sarif'
          output: 'trivy-results.sarif'

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and Push
        uses: docker/build-push-action@v3
        with:
          push: true
          tags: myorg/myapp:${{ github.sha }}

  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Staging
        run: ./deploy.sh staging ${{ github.sha }}
      
      - name: Run Smoke Tests
        run: ./smoke-tests.sh https://staging.example.com

  deploy-production:
    needs: deploy-staging
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to Production
        run: ./deploy.sh production ${{ github.sha }}
      
      - name: Verify Deployment
        run: ./verify-deployment.sh https://example.com
```

## 🔒 Security & Compliance

Security is built into every stage of our deployment process:

### Secure Secret Management

We use a combination of approaches to ensure secrets are securely managed:

#### AWS KMS for Encrypting Sensitive Data

```bash
# Encrypt a value using AWS KMS
aws kms encrypt \
    --key-id alias/my-app-key \
    --plaintext "my-secret-value" \
    --output text \
    --query CiphertextBlob > secret.enc

# Decrypt the value when needed
aws kms decrypt \
    --ciphertext-blob fileb://secret.enc \
    --output text \
    --query Plaintext | base64 --decode
```

### Role-Based Access Control (RBAC)

Implement least-privilege access with these examples:

#### AWS IAM Policy

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
      "Resource": "arn:aws:s3:::my-app-bucket/*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalTag/Role": "Developer"
        }
      }
    }
  ]
}
```

#### Kubernetes RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: my-app
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: my-app
subjects:
- kind: User
  name: developer@example.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

### Automated Security Scanning

We integrate security scanning throughout the pipeline:

#### OWASP ZAP for Dynamic Application Security Testing

```bash
# Start ZAP in daemon mode
zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true &

# Run an automated scan against the application
zap-cli quick-scan --self-contained \
    --start-options "-config api.disablekey=true" \
    https://staging-app.example.com

# Generate a security report
zap-cli report -o zap-report.html -f html
```

### Compliance Checks

- **CIS Benchmarks** — Ensure infrastructure complies with industry standards
- **SOC 2 Controls** — Implement controls for security, availability, and confidentiality
- **GDPR Compliance** — Built-in data protection measures for EU data subjects

## 🔄 Rollback Strategy

Our multi-layered rollback strategy ensures rapid recovery from failed deployments:

### Kubernetes Rollback

```bash
# Check deployment history
kubectl rollout history deployment/my-app

# Roll back to the previous version
kubectl rollout undo deployment/my-app

# Roll back to a specific revision
kubectl rollout undo deployment/my-app --to-revision=2
```

### Feature Flags for Controlled Rollout

```javascript
// Example using LaunchDarkly client
const ldClient = LaunchDarkly.initialize('YOUR_CLIENT_SIDE_ID', user);

ldClient.on('ready', () => {
  const showNewFeature = ldClient.variation('new-payment-ui', false);
  
  if (showNewFeature) {
    // Show new payment UI
  } else {
    // Show old payment UI
  }
});
```

### Automated Rollback in CI/CD

```yaml
name: Rollback Deployment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to rollback (staging|production)'
        required: true
      version:
        description: 'Version to rollback to (leave empty for previous)'
        required: false

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2
      
      - name: Rollback Deployment
        run: |
          if [ -z "${{ github.event.inputs.version }}" ]; then
            ./scripts/rollback.sh ${{ github.event.inputs.environment }}
          else
            ./scripts/rollback.sh ${{ github.event.inputs.environment }} ${{ github.event.inputs.version }}
          fi
      
      - name: Verify Rollback
        run: ./scripts/verify-deployment.sh ${{ github.event.inputs.environment }}
```

## 📊 Monitoring & Logging

Comprehensive observability ensures you can detect and respond to issues quickly:

### Prometheus Monitoring

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: web
    interval: 15s
    path: /metrics
```

### Grafana Dashboard

Our starter kit includes pre-configured Grafana dashboards for key metrics:

- Response time and error rates
- System resource utilization
- Deployment frequency and success rates
- Custom business metrics

### ELK Stack for Centralized Logging

```yaml
# Filebeat configuration
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/app/*.log
  json.keys_under_root: true
  json.add_error_key: true

processors:
  - add_kubernetes_metadata:
      host: ${NODE_NAME}
      matchers:
      - logs_path:
          logs_path: "/var/log/containers/"

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "app-logs-%{+yyyy.MM.dd}"
```

## 📚 Documentation

Comprehensive documentation is available at [https://nasa-ammos.github.io/slim/](https://nasa-ammos.github.io/slim/)

- **Getting Started Guide** — Quick start for new users
- **Architecture Overview** — Design principles and system architecture
- **Operator's Manual** — Day-to-day operations and troubleshooting
- **Security Guide** — Security best practices and compliance information

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## ❓ Frequently Asked Questions

### How do I customize the deployment pipeline for my application?

Edit the workflow files in `.github/workflows/` to add or modify steps specific to your application's build and deployment requirements.

### Can I use this with cloud providers other than AWS?

Yes! While our examples primarily use AWS, the principles and patterns apply to any cloud provider. Check the `infra/terraform/providers` directory for other provider configurations.

## 👥 Contributing

We welcome contributions from the community! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/awesome-feature
   ```
3. **Make your changes**
4. **Run tests**
   ```bash
   make test
   ```
5. **Commit your changes**
   ```bash
   git commit -m "Add awesome feature"
   ```
6. **Push to your branch**
   ```bash
   git push origin feature/awesome-feature
   ```
7. **Open a Pull Request**

Please read our [CONTRIBUTING.md](CONTRIBUTING.md) and [GOVERNANCE.md](GOVERNANCE.md) for more details.

## 📜 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

For support, questions, or feedback:

- **GitHub Issues**: Report bugs or request features
- **Discussions**: Ask questions and share ideas
- **Contact**: Reach out to [@yunks128](https://github.com/yunks128) or other maintainers
