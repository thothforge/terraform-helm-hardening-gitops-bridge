# Troubleshooting Guide

This guide provides comprehensive troubleshooting information for the Terraform Hardening GitOps Bridge Module.

## 🚨 Common Issues

### ArgoCD Not Starting
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-server
```

### DNS Resolution Issues
```bash
# Check External DNS logs
kubectl logs -n kube-system deployment/external-dns

# Verify Route53 permissions
aws route53 list-hosted-zones
```

### Load Balancer Issues
```bash
# Check AWS Load Balancer Controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Verify security group rules
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx
```

## 🔍 Debugging and Diagnostics

### Common Debugging Commands

#### ArgoCD Issues
```bash
# Check ArgoCD server status
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server

# View ArgoCD server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f

# Check ArgoCD applications
kubectl get applications -n argocd

# Describe specific application
kubectl describe application <app-name> -n argocd
```

#### Networking Issues
```bash
# Check security groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=*${cluster_name}*"

# Verify load balancer controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Check ingress resources
kubectl get ingress --all-namespaces
```

#### DNS Issues
```bash
# Check external-dns logs
kubectl logs -n kube-system deployment/external-dns

# Verify Route53 records
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>

# Test DNS resolution from pod
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup argocd.example.com
```

## ⚡ Performance Issues

### ArgoCD Performance Tuning
```yaml
# Increase ArgoCD server resources
server:
  resources:
    limits:
      cpu: 2
      memory: 4Gi
    requests:
      cpu: 1
      memory: 2Gi

# Optimize repository polling
configs:
  cm:
    timeout.reconciliation: 180s
    timeout.hard.reconciliation: 0s
```

### Network Performance
```bash
# Check network latency
kubectl run -it --rm debug --image=busybox --restart=Never -- ping google.com

# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
```

## 🔐 Security Incidents

### Incident Response Checklist
1. **Immediate Actions**
   - Isolate affected components
   - Preserve evidence
   - Notify security team

2. **Investigation**
```bash
# Check audit logs
kubectl logs -n kube-system kube-apiserver-*

# Review ArgoCD access logs
kubectl logs -n argocd deployment/argocd-server
```

3. **Recovery**
   - Apply security patches
   - Rotate compromised credentials
   - Update security policies

## 📋 Compliance and Auditing

### Audit Trail
```bash
# Enable audit logging
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Review ArgoCD application changes
kubectl get applications -n argocd -o yaml
```

### Compliance Checks
```bash
# Check pod security policies
kubectl get psp

# Verify network policies
kubectl get networkpolicies --all-namespaces

# Review RBAC configurations
kubectl get clusterroles,clusterrolebindings
```

## 🔍 Advanced Troubleshooting

### Performance Issues

#### ArgoCD Performance Tuning
```yaml
# Increase ArgoCD server resources
server:
  resources:
    limits:
      cpu: 2
      memory: 4Gi
    requests:
      cpu: 1
      memory: 2Gi

# Optimize repository polling
configs:
  cm:
    timeout.reconciliation: 180s
    timeout.hard.reconciliation: 0s
```

#### Network Performance
```bash
# Check network latency
kubectl run -it --rm debug --image=busybox --restart=Never -- ping google.com

# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
```

### Security Incidents

#### Incident Response Checklist
1. **Immediate Actions**
   - Isolate affected components
   - Preserve evidence
   - Notify security team

2. **Investigation**
```bash
# Check audit logs
kubectl logs -n kube-system kube-apiserver-*

# Review ArgoCD access logs
kubectl logs -n argocd deployment/argocd-server
```

3. **Recovery**
   - Apply security patches
   - Rotate compromised credentials
   - Update security policies

### Compliance and Auditing

#### Audit Trail
```bash
# Enable audit logging
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Review ArgoCD application changes
kubectl get applications -n argocd -o yaml
```

#### Compliance Checks
```bash
# Check pod security policies
kubectl get psp

# Verify network policies
kubectl get networkpolicies --all-namespaces

# Review RBAC configurations
kubectl get clusterroles,clusterrolebindings
```

## 🧪 Testing and Validation

### Pre-deployment Validation
```bash
# Validate Terraform configuration
terraform validate

# Plan deployment
terraform plan

# Check cluster connectivity
kubectl cluster-info

# Verify OIDC provider
aws iam list-open-id-connect-providers
```

### Post-deployment Testing
```bash
# Check ArgoCD installation
kubectl get pods -n argocd

# Verify addons deployment
kubectl get applications -n argocd

# Test DNS resolution
nslookup argocd.example.com

# Check load balancer status
kubectl get svc -n argocd
```

## 📞 Getting Help

If you're still experiencing issues after following this troubleshooting guide:

1. **Check the Examples**: Review the [examples](./examples/) directory for working configurations
2. **GitHub Issues**: Search existing issues or create a new one
3. **Community Support**: Join our community discussions
4. **Documentation**: Refer back to the main [README](./README.md) for configuration details

## 🔗 Related Documentation

- [Migration Guide](./MIGRATION.md) - For upgrading from other GitOps solutions
- [Upgrade Guide](./UPGRADE.md) - For version upgrades
- [Main README](./README.md) - Complete module documentation
