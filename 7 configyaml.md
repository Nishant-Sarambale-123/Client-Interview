Step 1: Create ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  ENVIRONMENT: "production"
  APP_MODE: "debug"


  Nice — you’ve created a **ConfigMap** for non-sensitive configuration 👍

Next, you typically need to **use this ConfigMap inside a Pod/Deployment**. Here are the common ways to do that:

***

## ✅ Option 1: Use ConfigMap as Environment Variables

This is the most common approach.

### Example Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        envFrom:
        - configMapRef:
            name: nginx-config
```

✅ This will create environment variables inside the container:

```
ENVIRONMENT=production
APP_MODE=debug
```

***

## ✅ Option 2: Use Individual Keys as Environment Variables

If you want to pick specific values:

```yaml
env:
- name: ENVIRONMENT
  valueFrom:
    configMapKeyRef:
      name: nginx-config
      key: ENVIRONMENT
- name: APP_MODE
  valueFrom:
    configMapKeyRef:
      name: nginx-config
      key: APP_MODE
```

***

## ✅ Option 3: Mount ConfigMap as Files (Volume)

This is useful if your app reads config files instead of env vars.

```yaml
spec:
  containers:
  - name: nginx
    image: nginx:latest
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: nginx-config
```

✅ Inside the container:

```
/etc/config/ENVIRONMENT
/etc/config/APP_MODE
```

Each key becomes a file.

***

## ✅ Step 2: Apply the ConfigMap

Run:

```bash
kubectl apply -f configmap.yaml
```

***

## ✅ Step 3: Verify ConfigMap

```bash
kubectl get configmap nginx-config
kubectl describe configmap nginx-config
```

***

## ✅ Best Practices

* ✔ Use **ConfigMap** for:
  * Environment configuration
  * Feature flags
  * Non-sensitive settings

* ❌ Don’t store:
  * Passwords
  * API keys  
    👉 Use **Secrets** instead

***

If you want, I can also show:
✅ Helm version of this  
✅ How to update ConfigMap without restarting pods  
✅ Real production patterns

Just tell 👍
