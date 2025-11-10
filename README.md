# 🚀 dbt-spark Docker Image

A lightweight, ready-to-use Docker image for running **dbt-spark** on **Spark 3.5.7**.  
This image is designed with **security best practices**, runs as a **non-root user**, and keeps the footprint minimal for fast deployment.

---

## ✨ Features

- 📦 **Out-of-the-box**: Preconfigured environment for dbt-spark  
- ⚡ **Easy to deploy**: Based on `python:3.11-slim` for quick builds  
- 🪶 **Lightweight**: Only essential dependencies included  
- 🔒 **Secure by default**: Runs as non-root user (`dbt`)  
- 🔗 **Compatible with Spark 3.5.7**: Configured for Spark Thrift Server integration  

---

## 🛠️ Usage


docker pull ghcr.io/datu1213/spark-dbt:1.2.7

On startup, the container will automatically run:
- `dbt deps`
- `dbt docs generate`
- `dbt docs serve --port 8580 --host 0.0.0.0`

Access the docs at: `http://localhost:8580`

---

## ⚙️ Environment Variables

| Name              | Description                                | Default Value                |
|-------------------|--------------------------------------------|------------------------------|
| `DBT_PROFILES_DIR`| Path to dbt profiles configuration         | `/home/dbt/app/conf`         |
| `SPARK_MASTER`    | Spark master connection string             | `spark://spark-thrift:7077`  |
| `THRIFT_HOST`     | Spark Thrift Server hostname               | `spark-thrift`               |
| `THRIFT_PORT`     | Spark Thrift Server port                   | `10000`                      |
| `DBT_DOCS_PORT`   | Port for dbt docs serve                    | `8580`                       |

---

## 👤 User & Security

- Default user: `dbt` (UID: 1001)  
- Project directory: `/home/dbt/app`  
- Runs without root privileges for enhanced security  

---

## 📂 Directory Structure

Inside the container:
```
/dbt/venv          # dbt virtual environment
/home/dbt/app      # mounted dbt project directory
/home/dbt/app/conf # dbt profiles.yml configuration directory
```

---

## 🔍 Use Cases

- Quickly bootstrap dbt-spark projects  
- Generate dbt documentation in CI/CD pipelines  
- Secure, lightweight integration with Spark Thrift Server  

---

## 📝 Example profiles.yml

```yaml
my_spark_project:
  target: dev
  outputs:
    dev:
      type: spark
      method: thrift
      host: ${THRIFT_HOST}
      port: ${THRIFT_PORT}
      schema: default
      user: dbt
      connect_timeout: 10
```

## Example docker-compose.yaml
```yaml
spark-dbt:
    image: ghcr.io/datu1213/spark-dbt:1.2.7
    depends_on:
      - spark-thrift
    environment:
      DBT_PROFILES_DIR: /home/dbt/app/conf
      SPARK_MASTER: spark://spark-thrift:7077
      THRIFT_HOST: spark-thrift
      THRIFT_PORT: 10000
      DBT_DOCS_PORT: 8580
    ports:
      - "8580:8580" # dbt-server UI
```
---

## 📖 Summary

This image provides a **secure, lightweight, and production-ready** environment for running **dbt-spark with Spark 3.5.7**.  
Mount your project directory, and you’re ready to generate and serve dbt docs instantly.

