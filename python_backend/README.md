# Python Backend

This is a Python backend service containerized with Docker.

## Prerequisites

- Python 3.11+
- Docker

## Setup and Running with Docker

1. **Install uv** (if not already installed):
   ```bash
   pip install uv
   ```

2. **Create and activate a virtual environment with uv**:
   ```bash
   # Create a new virtual environment
   uv venv
   
   # Activate the virtual environment
   # On Windows:
   .\.venv\Scripts\activate

   # On Unix or MacOS:
   # source .venv/bin/activate
   ```

3. **Install dependencies and sync with lock file**:
   ```bash
   # This will install dependencies from the uv.lock file
   uv sync
   ```

4. **Build and start the Docker containers**:
    Make sure that the Docker application is running in the background
   ```bash
   docker-compose build
   docker-compose up
   ```

## Environment Variables

Create a `.env` file in the project root and add any necessary environment variables. The `.env` file is automatically loaded by docker-compose.
