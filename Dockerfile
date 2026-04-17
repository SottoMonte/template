# --- STAGE 1: Build ---
FROM python:3-alpine AS builder

WORKDIR /app

# Tool necessari per compilare (se servono) e clonare
RUN apk add --no-cache build-base git

# 1. Installazione dipendenze (Uso --prefix per separare le lib dal sistema)
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# 2. Clonazione framework esterno (Clona solo l'ultima versione)
ARG REPO_URL="https://github.com/SottoMonte/frameworkkk"
RUN git clone --depth 1 ${REPO_URL} /tmp/repo && \
    mkdir -p src public && \
    cp -R /tmp/repo/src/* ./src/ && \
    cp -R /tmp/repo/public/* ./public/

# 3. Pulizia e Sovrascrittura LOCALE (Il tuo codice vince)
# Rimuoviamo la vecchia logica per non fare confusione
RUN rm -rf src/application

# COPIAMO I TUOI FILE LOCALI
COPY src/application ./src/application
COPY pyproject.toml ./pyproject.toml 

# --- STAGE 2: Runtime ---
FROM python:3-alpine AS runner

WORKDIR /app

# Variabili Ambiente per ottimizzare Python in Docker
ENV PYTHONPATH="/app" \
    PATH="/usr/local/bin:$PATH" \
    PORT=8000 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copia delle librerie (pre-compilate nel builder)
COPY --from=builder /install /usr/local

# Copia dei file finali
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/pyproject.toml ./pyproject.toml

EXPOSE ${PORT}

# Avvio
CMD ["python", "public/main.py"]