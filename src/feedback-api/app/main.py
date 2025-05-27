import logging
from fastapi import FastAPI

# Configure logging for debug output
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s %(name)s %(message)s',
)
logger = logging.getLogger(__name__)

app = FastAPI()

@app.get("/")
async def read_root():
    logger.debug("Root endpoint called")
    return {"message": "Hello World from API"}

@app.get("/api/hello")
async def read_api_hello():
    logger.debug("/api/hello endpoint called")
    return {"message": "Hello World from API endpoint /api/hello"}