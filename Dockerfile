# --- STAGE 1: Build ---
FROM python:3-alpine AS builder

WORKDIR /app

# Installiamo solo git (build-base rimosso se non strettamente necessario, aggiungilo se serve)
RUN apk add --no-cache git

# 1. CLONAZIONE (In una cartella isolata fuori da /app)
ARG REPO_URL="https://github.com/SottoMonte/frameworkkk"
RUN git clone --depth 1 ${REPO_URL} /tmp/framework_repo

# 2. COSTRUZIONE STRUTTURA (Solo i pezzi del framework che ti servono)
# Copiamo src e public, ma cancelliamo IMMEDIATAMENTE la cartella application remota
RUN mkdir -p /app/src /app/public && \
    cp -R /tmp/framework_repo/src/* /app/src/ && \
    cp -R /tmp/framework_repo/public/* /app/public/ && \
    rm -rf /app/src/application

# 3. INSTALLAZIONE DIPENDENZE (Nel builder)
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# 4. INIEZIONE FILE LOCALI (Questi devono sovrascrivere tutto)
# Usiamo COPY diretto sulla destinazione finale
COPY pyproject.toml /app/pyproject.toml
COPY src/application /app/src/application

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

# Copia i file generati nel builder
# NOTA: Copiando la cartella /app intera dal builder, prendiamo 
# esattamente la struttura che abbiamo pulito e montato sopra.
COPY --from=builder /app /app

EXPOSE ${PORT}

CMD ["python", "public/main.py"]