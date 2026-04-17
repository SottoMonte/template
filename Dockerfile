# --- STAGE 1: Build ---
FROM python:3-alpine AS builder

WORKDIR /app

# 1. Installazione tool minimi
RUN apk add --no-cache build-base libffi-dev git

# 2. CLONAZIONE FRAMEWORK (Per prendere il requirements.txt)
ARG REPO_URL="https://github.com/SottoMonte/frameworkkk"
RUN git clone --depth 1 ${REPO_URL} /tmp/framework_repo

# 3. INSTALLAZIONE DIPENDENZE (Dal framework)
# Usiamo il requirements.txt che sta dentro la repo appena clonata
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r /tmp/framework_repo/requirements.txt

# 4. PREPARAZIONE STRUTTURA /app
RUN mkdir -p /app/src && \
    cp -R /tmp/framework_repo/src/framework /app/src/framework && \
    cp -R /tmp/framework_repo/src/infrastructure /app/src/infrastructure && \
    cp -R /tmp/framework_repo/public /app/public

# 5. SOVRASCRITTURA/AGGIUNTA LOCALE
# Qui metti la tua logica specifica
COPY src/application /app/src/application
COPY pyproject.toml /app/pyproject.toml

# --- STAGE 2: Runtime ---
FROM python:3-alpine AS runner

WORKDIR /app

ENV PYTHONPATH="/app" \
    PATH="/usr/local/bin:$PATH" \
    PORT=8000 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copia librerie e codice dallo stage builder
COPY --from=builder /install /usr/local
COPY --from=builder /app /app

EXPOSE ${PORT}

CMD ["python", "public/main.py"]