ARG PYTHON_VERSION=3.11

# ---------- Stage 1: Build dependencies ----------
FROM python:${PYTHON_VERSION}-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libssl-dev \
    libthrift-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
# Prevent pip 25+ because of breaking changes
RUN pip install --upgrade "pip<25" setuptools wheel

# Install dbt-spark & PyHive
# Step by step to avoid dependency conflicts in installation process
RUN apt-get update && apt-get install -y --no-install-recommends \
      gcc \
      libsasl2-dev \
      python3-dev \
    && pip install --no-cache-dir \
      "dbt-core==1.8.7" \
      "dbt-spark[PyHive]==1.8.0" \
      pyhive>=0.7.0 \
      thrift>=0.16.0 \
      thrift-sasl>=0.4.3 \
      pure-sasl \
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

ENV DBT_PROFILES_DIR=/root/.dbt
ENV DBT_TARGET=spark
ENV SPARK_MASTER=spark://spark-thrift:7077
ENV THRIFT_HOST=spark-thrift
ENV THRIFT_PORT=10000 
ENV DBT_DOCS_PORT=8580

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/local/lib/python${PYTHON_VERSION}/site-packages /usr/local/lib/python${PYTHON_VERSION}/site-packages
COPY --from=builder /usr/local/bin/dbt /usr/local/bin/dbt
ADD my_dbt_project .

USER dbt

# dbt deps && dbt docs generate && exec dbt docs serve --port 8580 --host 0.0.0.0
CMD ["sh", "-c", "dbt deps && dbt docs generate && exec dbt docs serve --port ${DBT_DOCS_PORT} --host"]
EXPOSE 8580
