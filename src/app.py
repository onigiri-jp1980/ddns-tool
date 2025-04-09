import uvicorn
from fastapi import FastAPI
from mangum import Mangum
from os import environ as env

app = FastAPI()
handler = Mangum(app)


@app.get('/')
def hello():
    return {"detail": "Hello from FastAPI"}


if __name__ == "__main__":
    uvicorn.run(
        app="app:app",
        port=env.get('FASTAPI_PORT', 8000),
        host=env.get('FASTAPI_HOST', '0.0.0.0'),
        reload=bool(env.get('FASTAPI_RELOAD', False))
    )
