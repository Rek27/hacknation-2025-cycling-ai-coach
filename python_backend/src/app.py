from fastapi import FastAPI
from src.api.routers import health
from src.api.routers import stats
from src.api.routers import schedule
from src.api.routers import memory
from src.api.routers import weather
from mcp.server.fastmcp import FastMCP
from src.api.routers.mcp_server import register_tools


def app() -> FastAPI:
    project = FastAPI(title="Temp", version="1.0.0")
    project.include_router(health.router)
    project.include_router(stats.router)
    project.include_router(schedule.router)
    project.include_router(memory.router)
    project.include_router(weather.router)

    # Register MCP tools and mount the MCP HTTP app (exposes OpenAPI) at /mcp.
    # Also mount SSE app at /mcp/sse for event streaming if needed.
    mcp = FastMCP("cycling-tools")
    register_tools(mcp)
    # project.mount("/mcp", mcp.streamable_http_app())
    project.mount("/mcp/sse", mcp.sse_app())

    return project