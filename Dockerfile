# --- STAGE 1: Build ---
FROM python:3-alpine AS builder

WORKDIR /app

# Installazione tool minimi
RUN apk add --no-cache build-base libffi-dev git

# 1. CLONAZIONE FRAMEWORK
ARG REPO_URL="https://github.com/SottoMonte/frameworkkk"
RUN git clone --depth 1 ${REPO_URL} /tmp/framework_repo

# 2. CREAZIONE VIRTUAL ENV E INSTALLAZIONE
# Creiamo il venv in /opt/venv per isolarlo dal codice
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /tmp/framework_repo/requirements.txt

# 3. PREPARAZIONE STRUTTURA /app
RUN mkdir -p /app/src && \
    cp -R /tmp/framework_repo/src/framework /app/src/framework && \
    cp -R /tmp/framework_repo/src/infrastructure /app/src/infrastructure && \
    cp -R /tmp/framework_repo/public /app/public

# 4. AGGIUNTA CODICE LOCALE
COPY src/application /app/src/application
COPY pyproject.toml /app/pyproject.toml

# --- STAGE 2: Runtime ---
FROM python:3-alpine AS runner

# Creazione di un utente non-root per la sicurezza
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Variabili d'ambiente: puntiamo al Virtual Env e ottimizziamo Python
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH="/app" \
    PORT=8000 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copia del Virtual Env dallo stage builder
COPY --from=builder /opt/venv /opt/venv
# Copia dell'app e assegnazione dei permessi all'utente non-root
COPY --from=builder --chown=appuser:appgroup /app /app

# Cambio utente: da qui in poi nulla gira come root
USER appuser

EXPOSE ${PORT}

# Usiamo il path assoluto del venv per sicurezza
CMD ["/opt/venv/bin/python", "public/main.py"]