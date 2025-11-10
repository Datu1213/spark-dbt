ARG PYTHON_VERSION=3.11

# ---------- Stage 1: Build dependencies ----------
FROM python:${PYTHON_VERSION}-slim AS builder

COPY requirements.txt /tmp/requirements.txt

# Install dbt-spark & PyHive
# Step by step to avoid dependency conflicts in installation process
RUN apt-get update && apt-get install -y --no-install-recommends \
      gcc \
      libsasl2-dev \
      python3-dev \
      build-essential \
      libssl-dev \
    && pip install --upgrade pip setuptools wheel uv && \
    uv venv dbt && \
    . dbt/bin/activate && \
    uv pip install --no-cache-dir -vvv -r /tmp/requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache/pip

# ---------- Stage 2: Runtime image ----------

ARG PYTHON_VERSION   

FROM python:${PYTHON_VERSION}-slim

# Create a non-root user to run dbt
RUN useradd -m -u 1001 dbt \
    && mkdir -p /app \
    && chown -R dbt:dbt /app

WORKDIR /app

ARG PYTHON_VERSION

ENV PATH="dbt/bin:$PATH" \
    DBT_PROFILES_DIR=/root/.dbt \
    SPARK_MASTER=spark://spark-thrift:7077 \
    THRIFT_HOST=spark-thrift \
    THRIFT_PORT=10000 \
    DBT_DOCS_PORT=8580 

# Copy only the necessary files from the builder stage
COPY --from=builder dbt dbt
ADD my_dbt_project .

USER dbt

# dbt deps && dbt docs generate && exec dbt docs serve --port 8580 --host 0.0.0.0
CMD ["sh", "-c", "dbt deps && dbt docs generate && exec dbt docs serve --port ${DBT_DOCS_PORT} --host 0.0.0.0"]
EXPOSE 8580
