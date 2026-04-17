# --- STAGE 1: Build ---
FROM python:3-alpine AS builder

WORKDIR /app

# 1. Installazione tool di compilazione (Essenziali per molti requirements.txt)
RUN apk add --no-cache build-base libffi-dev git

# 2. INSTALLAZIONE DIPENDENZE
# Facciamolo prima di copiare il framework per sfruttare la cache
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt

# 3. CLONAZIONE FRAMEWORK (In cartella isolata)
ARG REPO_URL="https://github.com/SottoMonte/frameworkkk"
RUN git clone --depth 1 ${REPO_URL} /tmp/framework_repo

# 4. PREPARAZIONE STRUTTURA /app
# Copiamo tutto dal framework
RUN cp -R /tmp/framework_repo/src /app/src && \
    cp -R /tmp/framework_repo/public /app/public

# 5. SOVRASCRITTURA LOCALE (FORZATA)
# Rimuoviamo la cartella application del framework e mettiamo la TUA
RUN rm -rf /app/src/application
COPY src/application /app/src/application
# Copiamo il tuo pyproject.toml locale (sovrascrive quello del framework se esisteva)
COPY pyproject.toml /app/pyproject.toml

# --- STAGE 2: Runtime ---
FROM python:3-alpine AS runner

WORKDIR /app

ENV PYTHONPATH="/app" \
    PATH="/usr/local/bin:$PATH" \
    PORT=8000 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copia le librerie installate
COPY --from=builder /install /usr/local
# Copia l'intera cartella /app che abbiamo costruito con cura nel builder
COPY --from=builder /app /app

EXPOSE ${PORT}

CMD ["python", "public/main.py"]