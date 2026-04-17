# --- STAGE 1: Build ---
FROM python:3-alpine AS builder

WORKDIR /app

# Tool necessari
RUN apk add --no-cache build-base git

# 1. Installazione librerie (Cache efficiente)
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# 2. Clonazione del framework in una cartella TEMPORANEA
ARG REPO_URL="https://github.com/SottoMonte/frameworkkk"
RUN git clone --depth 1 ${REPO_URL} /tmp/repo

# 3. Costruzione struttura /app
# Copiamo tutto il framework, ma ESCLUDIAMO o CANCELLIAMO subito la loro cartella application
RUN mkdir -p src public && \
    cp -R /tmp/repo/src/* ./src/ && \
    cp -R /tmp/repo/public/* ./public/ && \
    rm -rf src/application  # <--- ELIMINIAMO i file remoti prima di mettere i tuoi

# 4. Iniezione file LOCALI (I tuoi file vincono sempre)
COPY pyproject.toml ./pyproject.toml
COPY src/application ./src/application

# --- STAGE 2: Runtime ---
FROM python:3-alpine AS runner

WORKDIR /app

ENV PYTHONPATH="/app" \
    PATH="/usr/local/bin:$PATH" \
    PORT=8000 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copia librerie
COPY --from=builder /install /usr/local

# Copia file pronti dal builder
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/pyproject.toml ./pyproject.toml

EXPOSE ${PORT}

CMD ["python", "public/main.py"]