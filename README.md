
# 🚀 Swiggy Clone – Production-Grade DevSecOps Deployment on AWS EKS

This project demonstrates a **fully automated DevSecOps pipeline** deploying a containerized React application to AWS EKS using:

* Infrastructure as Code (Terraform)
* Blue-Green Deployment Strategy
* AWS ALB Ingress Controller
* Horizontal Pod Autoscaler (HPA)
* Jenkins CI/CD
* SonarQube (SAST)
* OWASP Dependency Check (SCA)
* Docker & EKS

This project simulates how real production systems are deployed in cloud-native environments.

---

# 🏗️ Architecture Overview

```
User
  ↓
AWS Application Load Balancer (ALB)
  ↓
Kubernetes Ingress
  ↓
Service (swiggy-active)
  ↓
Blue / Green Deployments
  ↓
Pods (React + Nginx)
```

Infrastructure is fully provisioned using Terraform.

---

# ☁️ Infrastructure (Terraform)

Provisioned resources:

* Custom VPC
* Public & Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* IAM Roles
* EKS Cluster
* Managed Node Group

Terraform ensures:

* Reproducibility
* Version control
* Clean infra lifecycle

---

# 🔐 DevSecOps Pipeline (Jenkins)

Pipeline includes:

1. SonarQube Static Code Analysis
2. Quality Gate enforcement
3. OWASP Dependency vulnerability scan
4. Docker image build
5. Docker image push
6. Automated Blue-Green Deployment
7. Traffic switch validation

---

# 🔵🟢 Blue-Green Deployment Strategy

Two parallel deployments:

* swiggy-blue
* swiggy-green

A stable service:

* swiggy-active

Pipeline logic:

1. Detect active color
2. Deploy new version to inactive color
3. Wait for rollout
4. Switch service selector
5. Old version remains for rollback

Rollback is instant:

```
kubectl patch service swiggy-active \
-p '{"spec":{"selector":{"app":"swiggy","version":"blue"}}}'
```

Zero downtime deployment achieved.

---

# 📈 Autoscaling (HPA)

Horizontal Pod Autoscaler configured with:

* CPU-based scaling
* Min replicas: 2
* Max replicas: 6
* Metrics Server enabled

Ensures application scales automatically under load.

---

# 🌍 ALB Ingress Controller

* AWS Load Balancer Controller installed with IRSA
* ALB auto-provisioned
* Internet-facing routing
* IP target mode
* Works with Blue-Green strategy

---

# 🐳 Docker

* Multi-stage Dockerfile
* Lightweight Nginx-based runtime
* Image versioning via Jenkins build number

---

# 🛠️ Tech Stack

* AWS (EKS, IAM, ALB, VPC)
* Terraform
* Kubernetes
* Jenkins
* SonarQube
* OWASP Dependency Check
* Docker
* Nginx

---

# 🚀 How Deployment Works

On every Git push:

1. Jenkins runs SonarQube scan
2. Quality gate must pass
3. OWASP vulnerability scan runs
4. Docker image is built and pushed
5. Active color detected
6. Inactive deployment updated
7. Rollout validated
8. Service traffic switched
9. Zero downtime achieved

---

# 📊 Key Highlights

✔ Infrastructure as Code
✔ Fully automated CI/CD
✔ DevSecOps integration
✔ Blue-Green zero downtime
✔ Autoscaling enabled
✔ AWS-native ALB integration
✔ Manual rollback capability
✔ Production-style architecture

---

# 🧠 What This Project Demonstrates

This project demonstrates practical knowledge of:

* Kubernetes deployment patterns
* Cloud-native architecture
* Secure CI/CD practices
* High availability deployment strategies
* Infrastructure lifecycle management

---

# 📌 Future Improvements

* Canary deployment using ALB weighted routing
* Slack notification integration
* Terraform remote backend (S3 + DynamoDB)
* GitOps implementation
* Multi-environment separation (Dev/Prod)

---

# 📸 Demo

Access application via ALB DNS:

```
http://<ALB-DNS>
```

<img width="1916" height="973" alt="image" src="https://github.com/user-attachments/assets/52484afe-71d4-44f5-b134-5d9bd15afab2" />
<img width="1869" height="679" alt="image" src="https://github.com/user-attachments/assets/bc1d449d-3cf6-4ae9-b75e-f64b1288e8f1" />


---

# 👨‍💻 Author

Ayush Srivastava
DevOps Engineer | Cloud & Kubernetes Enthusiast

---


