from fastapi import FastAPI, Request
from app.model import generate_text
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI()

allowed_origins = os.getenv("ALLOWED_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
@app.post("/generate")
async def generate(payload: dict):
    prompt = (payload or {}).get("prompt", "")
    text = generate_text(prompt)
    return {"output": text, "response": text}

@app.get("/healthz")
def healthz():
    return {"ok": True}