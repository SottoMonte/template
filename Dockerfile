# --- STAGE 1: Build ---
FROM python:3-alpine AS builder

WORKDIR /app

# 1. Installazione tool di compilazione (Essenziali per pacchetti C/C++ o Git)
RUN apk add --no-cache build-base libffi-dev git

# 2. INSTALLAZIONE DIPENDENZE
# Copiamo il file dei requisiti e installiamo le librerie in una cartella isolata (/install)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt

# 3. CLONAZIONE FRAMEWORK
ARG REPO_URL="https://github.com/SottoMonte/frameworkkk"
RUN git clone --depth 1 ${REPO_URL} /tmp/framework_repo

# 4. PREPARAZIONE STRUTTURA /app
# Creiamo la cartella src e copiamo selettivamente le directory dal framework
RUN mkdir -p /app/src && \
    cp -R /tmp/framework_repo/src/framework /app/src/framework && \
    cp -R /tmp/framework_repo/src/infrastructure /app/src/infrastructure && \
    cp -R /tmp/framework_repo/public /app/public

# 5. SOVRASCRITTURA/AGGIUNTA LOCALE
# Copiamo la tua logica di business e la configurazione del progetto
COPY src/application /app/src/application
COPY pyproject.toml /app/pyproject.toml

# --- STAGE 2: Runtime ---
FROM python:3-alpine AS runner

# Impostiamo la cartella di lavoro standard
WORKDIR /app

# Variabili d'ambiente per ottimizzare Python in Docker
ENV PYTHONPATH="/app" \
    PATH="/usr/local/bin:$PATH" \
    PORT=8000 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copiamo solo il necessario dallo stage di build
# - Le librerie Python installate (da /install a /usr/local)
# - La struttura dell'app che abbiamo costruito con cura
COPY --from=builder /install /usr/local
COPY --from=builder /app /app

# Porta utilizzata dall'app
EXPOSE ${PORT}

# Avvio dell'applicazione
CMD ["python", "public/main.py"]