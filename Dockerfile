# Stage 1: Build stage - Install dependencies and prepare the app
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir \
    -i https://mirror-pypi.runflare.com/simple \
    --trusted-host mirror-pypi.runflare.com \
    -r requirements.txt

# Copy the entire project (application code + any other needed files)
COPY . .

# Stage 2: Runtime stage - Final small image
FROM python:3.11-slim

# Create a non-root user and group (best practice for security)
RUN addgroup --system appgroup && \
    adduser --system --group --no-create-home appuser

# Set working directory
WORKDIR /app

# Copy installed Python packages and binaries from builder stage
# Use --chown to set correct ownership right away
COPY --from=builder --chown=appuser:appgroup /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder --chown=appuser:appgroup /usr/local/bin /usr/local/bin

# Copy application code with correct ownership
COPY --chown=appuser:appgroup . .

# Switch to non-root user (very important for security)
USER appuser

# Run the FastAPI application
CMD ["fastapi", "run"]
