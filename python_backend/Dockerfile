FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

WORKDIR /app

COPY pyproject.toml uv.lock main.py ./

RUN uv sync --locked

COPY src ./src
ENV PATH="/app/.venv/bin:$PATH" 

EXPOSE 8001
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--reload", "--proxy-headers", "--factory"]