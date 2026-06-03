Here is a **complete end-to-end interview answer** (clean, structured, and correct) 👇

***

# ✅ Step 1: Dockerfile (Containerize Java App)

```dockerfile
# Stage 1: Build the application
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

***

# ✅ Step 2: Build, Tag, and Push Docker Image

### Build image

```bash
docker build -t myapp .
```

### Tag image

```bash
docker tag myapp nishant123/myapp:v1
```

### Push to Docker Hub (or any registry)

```bash
docker push nishant123/myapp:v1
```

***

# ✅ Step 3: Kubernetes Deployment YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-app-deployment
  labels:
    app: java-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: java-app
  template:
    metadata:
      labels:
        app: java-app
    spec:
      containers:
      - name: java-container
        image: nishant123/myapp:v1
        ports:
        - containerPort: 8080
```

***

# ✅ Step 4: Service YAML (LoadBalancer)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: java-app-service
spec:
  type: LoadBalancer
  selector:
    app: java-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

***

# ✅ Step 5: Apply on Kubernetes Cluster

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

***

# ✅ Step 6: Verify

```bash
kubectl get pods
kubectl get svc
```

***

# ✅ Step 7: Access Application

👉 After LoadBalancer is created:

```text
http://<EXTERNAL-IP>
```

(You get EXTERNAL-IP from `kubectl get svc`)

***

# ✅ Final Interview Answer (Perfect)

> "First, I containerize the Java app using a multi-stage Dockerfile. Then I build, tag, and push the image to a registry like Docker Hub. After that, I create a Kubernetes Deployment to run multiple replicas and expose it using a LoadBalancer Service. Once deployed, I access the application using the external IP provided by the LoadBalancer."

***

# ✅ Bonus Points (if interviewer asks further)

* Use **ConfigMaps & Secrets** for configuration
* Use **Ingress** for domain-based routing
* Use **HPA** for auto-scaling
* Use **CI/CD pipeline** for automation

***

If you want, I can give next-level answer:
✅ Helm chart version  
✅ Ingress setup with domain  
✅ Production architecture

Just say 👍
