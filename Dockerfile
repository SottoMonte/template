# Stage 1: Build
FROM python:3-alpine AS builder

# Variabili per la build
ARG REPO_URL="https://github.com/SottoMonte/frameworkkk"
ARG BUILD_TIMESTAMP=unknown

WORKDIR /app

# 1. Installazione dipendenze di sistema necessarie per la compilazione
RUN apk add --no-cache build-base python3-dev libffi-dev git

# 2. Creazione Virtual Environment reale
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 3. Installazione dipendenze (Massimizza il caching)
# Copiamo solo i file dei requisiti prima del resto
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 4. Gestione Codice Sorgente
# Cloniamo in una directory temporanea e spostiamo solo ciò che serve
RUN git clone ${REPO_URL} /tmp/repo && \
    mkdir -p public && \
    cp -R /tmp/repo/public/* public/ 2>/dev/null || true && \
    cp -R /tmp/repo/src src/ 2>/dev/null || true

# 5. Sovrascrittura locale (se presente nel contesto di build)
# Rimuoviamo la parte specifica che vuoi sostituire e copiamo la nuova
RUN rm -rf src/application
COPY src/application src/application

# ---

# Stage 2: Runtime (Immagine finale leggera)
FROM python:3-alpine AS runner

WORKDIR /app

# Variabili d'ambiente
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH="/app" \
    PORT=8000 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 1. Creazione utente non-root per sicurezza
RUN adduser -D appuser && \
    mkdir -p /app && chown appuser:appuser /app

# 2. Copia solo l'essenziale dallo stage builder
COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv
COPY --from=builder --chown=appuser:appuser /app/src ./src
COPY --from=builder --chown=appuser:appuser /app/public ./public
COPY --from=builder --chown=appuser:appuser /app/requirements.txt .

USER appuser

EXPOSE ${PORT}

# Usa il modulo python se main.py è un entry point
CMD ["python", "public/main.py"]