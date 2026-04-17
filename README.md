# OmniPort Application Template

Un template scaffolder per creare rapidamente applicazioni utilizzando il framework OmniPort con architettura esagonale (Ports & Adapters).

## ℹ️ Panoramica

Questo repository serve come punto di partenza per nuovi progetti OmniPort. Contiene una struttura predefinita, configurazioni base e esempi per iniziare lo sviluppo seguendo i principi dell'architettura esagonale.

## 📋 Requisiti

- Python >= 3.9
- Docker (opzionale, per containerizzazione)

## 🚀 Avvio Rapido

### 1. Clonare il template

```bash
git clone <repository-url> <project-name>
cd <project-name>
```

### 2. Installare le dipendenze

```bash
pip install -r requirements.txt
```

O usando Poetry:

```bash
poetry install
```

### 3. Configurare il progetto

Modificare `pyproject.toml` con:
- Nome del progetto
- Descrizione
- Configurazioni dei backend (autenticazione, persistenza, messaggistica)
- Impostazioni di presentazione (host e porta)

### 4. Avviare l'applicazione

```bash
python -m src.application
```

L'applicazione sarà disponibile all'indirizzo configurato (default: http://localhost:5000)

## 📁 Struttura del Progetto

```
src/application/
├── controller/          # Gestori delle richieste HTTP
├── model/              # Entità di dominio e schemi
├── policy/             # Regole di sicurezza e business logic
├── view/               # Definizioni dell'interfaccia utente
│   ├── component/      # Componenti UI riutilizzabili
│   ├── layout/         # Layout condivisi
│   ├── page/           # Pagine dell'applicazione
│   └── template/       # Template HTML/DSL
```

### Regole di Modifica

✅ **Puoi modificare:**
- File all'interno di `src/application/` e sottodirectory
- `pyproject.toml` per la configurazione

❌ **Non toccare:**
- `src/infrastructure/` - Implementazioni di infrastruttura
- `src/framework/` - Il motore del framework

## ⚙️ Configurazione

### Autenticazione (pyproject.toml)

```toml
[authentication.backend]
adapter = "supabase"  # o altri adapter supportati
url = "..."
key = "..."
```

### Persistenza dei Dati

```toml
[persistence.API]
adapter = "api"       # o "database", "redis", etc.
url = "..."
```

### Presentazione (Web)

```toml
[presentation.backend]
adapter = "starlette"
host = "0.0.0.0"
port = "5000"
```

## 📚 Documentazione

Per informazioni dettagliate sull'utilizzo del framework OmniPort, consulta [SKILL.md](SKILL.md).

## 🐳 Docker

Per containerizzare l'applicazione:

```bash
docker build -t my-app .
docker run -p 5000:5000 my-app
```

## 📝 Licenza

Specificare la licenza del progetto qui.

## 🤝 Contributi

Per linee guida sui contributi, vedere CONTRIBUTING.md (da creare se necessario).

---

**Buon sviluppo! 🚀**
