from transformers import AutoModelForCausalLM, AutoTokenizer
import torch, os

# keep the same variable name; allow overriding via env
model_name = os.getenv("HF_MODEL_ID", "Qwen/Qwen2.5-1.5B-Instruct")

tokenizer = AutoTokenizer.from_pretrained(model_name, use_fast=True)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype=torch.float32,   # CPU-friendly
)
model.eval()

# make sure we have a pad token
if tokenizer.pad_token_id is None:
    tokenizer.pad_token = tokenizer.eos_token

SYSTEM_PROMPT = os.getenv("SYSTEM_PROMPT", "You are a concise, helpful assistant.")

def _format_prompt(prompt: str) -> str:
    """Use chat template when available so the model follows instructions well."""
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": prompt.strip()},
    ]
    if hasattr(tokenizer, "apply_chat_template"):
        return tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    # fallback if a model lacks a chat template
    return f"{SYSTEM_PROMPT}\nUser: {prompt.strip()}\nAssistant:"

@torch.no_grad()
def generate_text(prompt: str) -> str:
    text = _format_prompt(prompt)
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=2048)
    outputs = model.generate(
        **inputs,
        max_new_tokens=160,
        do_sample=False,  # deterministic for demos
        pad_token_id=tokenizer.pad_token_id,
        eos_token_id=tokenizer.eos_token_id,
    )
    # return only the newly generated tokens (not the prompt)
    gen_ids = outputs[0][inputs["input_ids"].shape[-1]:]
    return (tokenizer.decode(gen_ids, skip_special_tokens=True).strip() or "(no answer)")