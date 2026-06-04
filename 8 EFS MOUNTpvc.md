To **mount NFS on AWS as a Persistent Volume (PV) in an EKS cluster**, the most common and recommended approach is to use **Amazon EFS (Elastic File System)** as your NFS backend.

Below is a **complete step-by-step from scratch guide** 👇

***

# ✅ Architecture Overview

* **Amazon EFS** → Managed NFS storage
* **EKS cluster** → Kubernetes
* **EFS CSI Driver** → Connects EKS to EFS
* **Persistent Volume (PV)** → Represents EFS
* **Persistent Volume Claim (PVC)** → Used by Pods

***

# 🧱 Step 1: Create EFS File System

### 1.1 Create EFS

```bash
aws efs create-file-system \
  --region <region> \
  --performance-mode generalPurpose \
  --throughput-mode bursting
```

### 1.2 Create Mount Targets (IMPORTANT)

EFS must be accessible in your VPC subnets:

```bash
aws efs create-mount-target \
  --file-system-id <efs-id> \
  --subnet-id <subnet-id> \
  --security-groups <sg-id>
```

Repeat for each AZ/subnet where EKS nodes run.

***

# 🔐 Step 2: Security Group

Allow NFS access (port **2049**) from EKS worker nodes:

```
Type: NFS
Port: 2049
Source: EKS node security group
```

***

# ⚙️ Step 3: Install EFS CSI Driver on EKS

### Option A: Using Helm (recommended)

```bash
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update

helm install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
  -n kube-system
```

***

### Option B: AWS Managed Add-on

```bash
aws eks create-addon \
  --cluster-name <cluster-name> \
  --addon-name aws-efs-csi-driver
```

***

# 🔑 Step 4: IAM Role for Service Account (IRSA)

Create IAM role with policy:

```json
{
  "Effect": "Allow",
  "Action": [
    "elasticfilesystem:*"
  ],
  "Resource": "*"
}
```

Bind it to service account (`efs-csi-controller-sa`).

***

# 📦 Step 5: Create StorageClass

## Dynamic Provisioning (Recommended)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: <efs-id>
  directoryPerms: "700"
```

Apply:

```bash
kubectl apply -f storageclass.yaml
```

***

# 📄 Step 6: Create PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
```

Apply:

```bash
kubectl apply -f pvc.yaml
```

***

# 🚀 Step 7: Use PVC in a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: efs-test-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - mountPath: "/data"
      name: efs-storage
  volumes:
  - name: efs-storage
    persistentVolumeClaim:
      claimName: efs-pvc
```

***

# 📂 Step 8: Verify Mount

Exec into pod:

```bash
kubectl exec -it efs-test-pod -- bash
```

Check mount:

```bash
df -h
```

or

```bash
mount | grep efs
```

***

# 🧠 Alternative: Static PV (Manual NFS Mount)

If using external NFS (not EFS):

### PV definition

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <nfs-server-ip>
    path: /exported/path
```

### PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```

***

# ✅ Key Concepts

| Component    | Purpose                 |
| ------------ | ----------------------- |
| EFS          | NFS storage             |
| CSI Driver   | Kubernetes ↔ AWS bridge |
| StorageClass | Template for volumes    |
| PV           | Real storage definition |
| PVC          | Request for storage     |

***

# ⚠️ Common Issues

* ❌ Mount timeout → Check security group (port 2049)
* ❌ Pods stuck → Check CSI driver logs:
  ```bash
  kubectl logs -n kube-system -l app=efs-csi-controller
  ```
* ❌ Access denied → IAM/IRSA issue

***

# 🎯 Best Practice

✅ Use:

* EFS + CSI driver
* Dynamic provisioning
* ReadWriteMany access

❌ Avoid:

* Manual NFS unless required
* Hardcoding IPs

***

# ✅ Summary

1. Create **EFS (NFS)**
2. Allow **SG access (2049)**
3. Install **EFS CSI driver**
4. Create **StorageClass**
5. Create **PVC**
6. Mount in **Pod**

***

If you want, I can also:
✅ Show Terraform setup  
✅ Provide complete YAML bundle  
✅ Debug your current setup

Just tell me 👍
