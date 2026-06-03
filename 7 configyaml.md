Here’s everything rewritten in a **clean, production-ready, properly structured format** ✅

***

# ✅ Step 1: Create ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  ENVIRONMENT: "production"
  APP_MODE: "debug"
```

***

# ✅ Option 1: Use ConfigMap as Environment Variables (Recommended)

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

### ✅ Result inside container:

```bash
ENVIRONMENT=production
APP_MODE=debug
```

***

# ✅ Option 2: Use Specific Keys as Environment Variables

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-specific
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-specific
  template:
    metadata:
      labels:
        app: nginx-specific
    spec:
      containers:
      - name: nginx
        image: nginx:latest
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

# ✅ Option 3: Mount ConfigMap as Volume (Files)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-volume
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-volume
  template:
    metadata:
      labels:
        app: nginx-volume
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

### ✅ Files inside container:

```
/etc/config/ENVIRONMENT
/etc/config/APP_MODE
```

***

# ✅ Step 2: Apply Resources

```bash
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
```

***

# ✅ Step 3: Verify

```bash
kubectl get configmap nginx-config
kubectl describe configmap nginx-config

kubectl get pods
kubectl exec -it <pod-name> -- env | grep ENV
```

***

# ✅ Optional: Helm Version (Production Style)

### `values.yaml`

```yaml
config:
  ENVIRONMENT: production
  APP_MODE: debug
```

### `configmap.yaml` (Helm template)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  ENVIRONMENT: "{{ .Values.config.ENVIRONMENT }}"
  APP_MODE: "{{ .Values.config.APP_MODE }}"
```

### `deployment.yaml` (Helm template)

```yaml
envFrom:
- configMapRef:
    name: {{ .Release.Name }}-config
```

***

# ✅ Updating ConfigMap Without Restarting Pods

### 🔹 Method 1: Manual restart (most common)

```bash
kubectl rollout restart deployment nginx-deployment
```

***

### 🔹 Method 2: Auto reload (advanced)

Use annotation trick:

```yaml
metadata:
  annotations:
    configmap.revision: "{{ randAlphaNum 5 }}"
```

OR use tools like:

* Reloader (Stakater)
* Kubernetes Operators

***

# ✅ Best Practices

### ✔ Use ConfigMap for:

* Environment configuration
* Feature flags
* Application settings

### ❌ Avoid storing:

* Passwords
* API keys
* Tokens

👉 Use **Kubernetes Secrets** instead

***

# ✅ Pro Tips (Real Production Usage)

* Use **envFrom** for simple apps
* Use **volume mount** if app reads config files
* Combine **ConfigMap + Secret**
* Version your configs (e.g., `nginx-config-v2`)
* Use **Helm or Kustomize** for manageability

***

If you want next level 🚀, I can show:

* ✅ ConfigMap + Secret combined pattern
* ✅ Kustomize version
* ✅ Auto-reload without pod restart (live demo style)
* ✅ Real microservices production setup

Just tell 👍
