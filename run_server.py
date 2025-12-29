#!/usr/bin/env python
"""
Wrapper script to run the A2A server with proper import paths
"""
import os
import sys
from pathlib import Path

# Get the src directory
src_dir = Path(__file__).parent / "src"
if str(src_dir) not in sys.path:
    sys.path.insert(0, str(src_dir))

# Now import and run
import uvicorn
from a2a.main import app

if __name__ == "__main__":
    host = os.getenv("HOST", "127.0.0.1")
    port = int(os.getenv("PORT", 8001))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    uvicorn.run(app, host=host, port=port, reload=debug)
