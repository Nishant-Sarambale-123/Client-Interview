For **AWS EBS as Persistent Volume in EKS**, the setup is different from NFS/EFS because **EBS is block storage (not shared)**.

👉 Key point:

* ✅ EBS supports **ReadWriteOnce (RWO)** → only one pod/node at a time
* ❌ Not like NFS (EFS) → no multi-node sharing

Below is a **complete from scratch setup** 👇

***

# ✅ Architecture Overview

* **Amazon EBS** → Block storage
* **EBS CSI Driver** → Connects Kubernetes to EBS
* **StorageClass** → Defines EBS volume creation
* **PVC** → Requests EBS volume
* **Pod** → Uses volume

***

# 🧱 Step 1: Install EBS CSI Driver

### Option 1: AWS Managed Add-on (Recommended)

```bash
aws eks create-addon \
  --cluster-name <cluster-name> \
  --addon-name aws-ebs-csi-driver
```

***

### Option 2: Helm

```bash
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  -n kube-system
```

***

# 🔑 Step 2: IAM Role (IRSA)

Create IAM policy:

```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateVolume",
    "ec2:DeleteVolume",
    "ec2:AttachVolume",
    "ec2:DetachVolume",
    "ec2:DescribeVolumes",
    "ec2:DescribeInstances"
  ],
  "Resource": "*"
}
```

Attach it to service account:

```
ebs-csi-controller-sa
```

***

# 📦 Step 3: Create StorageClass

## ✅ Dynamic Provisioning (Recommended)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
  fsType: ext4
```

Apply:

```bash
kubectl apply -f storageclass.yaml
```

***

# 📄 Step 4: Create PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 10Gi
```

Apply:

```bash
kubectl apply -f pvc.yaml
```

***

# 🚀 Step 5: Use PVC in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ebs-test-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - mountPath: "/data"
      name: ebs-storage
  volumes:
  - name: ebs-storage
    persistentVolumeClaim:
      claimName: ebs-pvc
```

***

# 🔍 Step 6: Verify

```bash
kubectl get pvc
kubectl get pv
```

Exec pod:

```bash
kubectl exec -it ebs-test-pod -- bash
df -h
```

***

# 📌 Important Behavior

### 🔒 Single Node Attachment

* EBS volume attaches to **only one node at a time**
* If pod moves → volume re-attaches

***

# 🧠 Static PV (Manual EBS)

If you already have an EBS volume:

### Step 1: Create PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ebs-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  awsElasticBlockStore:
    volumeID: <volume-id>
    fsType: ext4
```

***

### Step 2: PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-static-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

***

# ✅ Best Practices

✅ Use:

* **gp3 volumes**
* **WaitForFirstConsumer**
* CSI driver (not in-tree)

❌ Avoid:

* Using EBS for shared storage
* Hardcoding AZ mismatch

***

# ⚠️ Common Issues

### ❌ Pod stuck in Pending

* AZ mismatch between node & EBS
* Fix: Use `WaitForFirstConsumer`

***

### ❌ Multi-pod mount fail

* Because EBS = RWO only

***

### ❌ Volume attach error

Check logs:

```bash
kubectl logs -n kube-system -l app=ebs-csi-controller
```

***

# 🔄 EBS vs EFS Quick Comparison

| Feature     | EBS                | EFS            |
| ----------- | ------------------ | -------------- |
| Type        | Block              | NFS            |
| Access      | Single node        | Multi-node     |
| Performance | High (low latency) | Shared         |
| Use case    | DB, stateful apps  | Shared storage |

***

# ✅ Summary

1. Install **EBS CSI driver**
2. Configure **IAM (IRSA)**
3. Create **StorageClass**
4. Create **PVC**
5. Mount in **Pod**

***

If you want next level:
✅ StatefulSet with EBS  
✅ Multi-AZ design patterns  
✅ Helm chart example

Just tell me 👍
