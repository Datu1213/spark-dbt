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
RUN pip install --no-cache-dir "dbt-core==1.8.7" && \
    pip install --no-cache-dir "dbt-spark==1.8.0" && \
    pip install --no-cache-dir dbt-spark[Pyhive] \
    && rm -rf /root/.cache/pip


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

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/local/lib/python${PYTHON_VERSION}/site-packages /usr/local/lib/python${PYTHON_VERSION}/site-packages
COPY --from=builder /usr/local/bin/dbt /usr/local/bin/dbt
ADD my_dbt_project .

USER dbt

EXPOSE 8580
