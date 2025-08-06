FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY app/ ./app

ENV TRANSFORMERS_CACHE=/app/.cache

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0,0,0,0", "--port", "8080"]