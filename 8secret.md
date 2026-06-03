Here’s the equivalent **`Secret` YAML** for your ConfigMap example 👇

***

## ✅ Step 1: Create Secret (secret.yaml)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: nginx-secret
type: Opaque
data:
  ENVIRONMENT: cHJvZHVjdGlvbg==
  APP_MODE: ZGVidWc=
```

***

## 🔐 Important: Base64 Encoding

Kubernetes **Secrets require values to be base64 encoded**.

Your original values:

```
production → cHJvZHVjdGlvbg==
debug      → ZGVidWc=
```

👉 You can generate these using:

```bash
echo -n "production" | base64
echo -n "debug" | base64
```

***

## ✅ Alternative (Easier): Use `stringData` (No Encoding Needed)

You can avoid manual encoding like this:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: nginx-secret
type: Opaque
stringData:
  ENVIRONMENT: "production"
  APP_MODE: "debug"
```

✅ Kubernetes will automatically convert it to base64.

***

## ✅ Step 2: Apply Secret

```bash
kubectl apply -f secret.yaml
```

***

## ✅ Step 3: Use Secret in Deployment

### Option 1: As Environment Variables

```yaml
envFrom:
- secretRef:
    name: nginx-secret
```

***

### Option 2: Specific Keys

```yaml
env:
- name: ENVIRONMENT
  valueFrom:
    secretKeyRef:
      name: nginx-secret
      key: ENVIRONMENT
- name: APP_MODE
  valueFrom:
    secretKeyRef:
      name: nginx-secret
      key: APP_MODE
```

***

### Option 3: Mount as Volume

```yaml
volumeMounts:
- name: secret-volume
  mountPath: /etc/secret

volumes:
- name: secret-volume
  secret:
    secretName: nginx-secret
```

***

## ✅ Verify Secret

```bash
kubectl get secret nginx-secret
kubectl describe secret nginx-secret
```

To decode:

```bash
echo cHJvZHVjdGlvbg== | base64 --decode
```

***

## ✅ Best Practices

| Use ConfigMap        | Use Secret        |
| -------------------- | ----------------- |
| Non-sensitive config | Sensitive data    |
| ENV flags            | API keys          |
| App settings         | Passwords, tokens |

***

If you want next:
✅ How to use Secrets with Helm  
✅ How to rotate secrets safely  
✅ External secret managers (Vault, AWS Secrets Manager)

Just tell 👍
