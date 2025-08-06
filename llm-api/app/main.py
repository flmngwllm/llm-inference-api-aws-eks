from fastapi import FastAPI, Request
from model import generate_text

app = FastAPI()

@app.post("/generate")
async def generate(request: Request):
    data = await request.json()
    prompt = data.get("prompt", "")
    output = generate_text(prompt)
    return {"response": output}