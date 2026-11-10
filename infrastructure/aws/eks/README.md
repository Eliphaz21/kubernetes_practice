# AWS EKS Cluster Add-ons Guide

## CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

## 1. AWS Load Balancer Controller (ALB)
In Minikube, we use the standard Nginx Ingress Controller. In AWS EKS, we use the **AWS Load Balancer Controller**, which automatically provisions an **Application Load Balancer (ALB)** in AWS when you create an Ingress resource.

### Installation via Helm
```powershell
# 1. Add EKS Helm Charts repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# 2. Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller `
  -n kube-system `
  --set clusterName=csec-welcome-eks `
  --set serviceAccount.create=false `
  --set serviceAccount.name=aws-load-balancer-controller
```

---

## 2. Amazon EBS CSI Driver (Persistent Storage on AWS)
Allows Kubernetes to dynamically provision AWS Elastic Block Store (EBS) volumes:
```powershell
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver `
  --namespace kube-system
```
