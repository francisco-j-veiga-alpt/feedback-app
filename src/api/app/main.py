from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Hello World from API OK"}

@app.get("/api/hello")
async def read_api_hello():
    return {"message": "Hello World from API endpoint /api/hello"}
