import os
import sys
import logging
from contextlib import asynccontextmanager
from pathlib import Path

import httpx
from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from dotenv import load_dotenv

# Add src directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from a2a.api.chat import router as chat_router
# from a2a.agent.a2a_server import A2AServer  # Disabled due to missing a2a.server module

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global variables for cleanup
httpx_client: httpx.AsyncClient = None
# a2a_server: A2AServer = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifespan"""
    global httpx_client
    
    # Startup
    logger.info("Starting Zava Product Manager...")
    httpx_client = httpx.AsyncClient(timeout=30)
    
    logger.info(
        f"Chat API available at http://localhost:8001/api/chat/message"
    )
    
    yield
    
    # Shutdown
    logger.info("Shutting down Zava Product Manager...")
    if httpx_client:
        await httpx_client.aclose()


# Create FastAPI app
app = FastAPI(
    title="Zava Product Manager",
    description=(
        "A standalone web application for Zava Product Manager"
    ),
    version="1.0.0",
    lifespan=lifespan
)

# Mount static files
static_path = Path(__file__).parent / "static"
app.mount("/static", StaticFiles(directory=static_path), name="static")

# Setup templates
templates_path = Path(__file__).parent / "templates"
templates = Jinja2Templates(directory=templates_path)

# Include API routes
app.include_router(chat_router, prefix="/api")


@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    """Serve the main chat interface"""
    return templates.TemplateResponse("index.html", {"request": request})


@app.get("/health")
async def health_check():
    """Health check endpoint for Azure App Service"""
    return {"status": "healthy", "service": "zava-product-manager"}
    return {"error": "A2A server not initialized"}


if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8001))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    uvicorn.run(app, host=host, port=port, reload=debug)
