mport os, torch
from transformers import AutoTokenizer, AutoModelForCausalLM

# Small, CPU-friendly instruct model (override via env if you want)
MODEL_NAME = os.getenv("MODEL_NAME", "Qwen/Qwen2.5-0.5B-Instruct")

tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME, use_fast=True)
model = AutoModelForCausalLM.from_pretrained(
    MODEL_NAME,
    torch_dtype=torch.float32,     # ✅ faster/more reliable on CPU than float16
    low_cpu_mem_usage=True,
)
model.eval()

# Make sure we have a pad token
if tokenizer.pad_token_id is None:
    tokenizer.pad_token = tokenizer.eos_token

# Tighter, fast-by-default limits
MAX_INPUT_TOKENS = int(os.getenv("MAX_INPUT_TOKENS", "512"))
MAX_NEW_TOKENS   = int(os.getenv("MAX_NEW_TOKENS", "64"))
DO_SAMPLE        = os.getenv("DO_SAMPLE", "false").lower() == "true"  # deterministic default
TEMPERATURE      = float(os.getenv("TEMPERATURE", "0.7"))
TOP_P            = float(os.getenv("TOP_P", "0.95"))

# Optional: keep CPU threads tame for small nodes
torch.set_num_threads(int(os.getenv("TORCH_NUM_THREADS", "1")))

@torch.no_grad()
def generate_text(prompt: str) -> str:
    messages = [{"role": "user", "content": prompt}]
    templated = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    inputs = tokenizer(
        templated,
        return_tensors="pt",
        truncation=True,
        max_length=MAX_INPUT_TOKENS,
    )
    outputs = model.generate(
        **inputs,
        max_new_tokens=MAX_NEW_TOKENS,
        do_sample=DO_SAMPLE,
        temperature=TEMPERATURE,
        top_p=TOP_P,
        eos_token_id=tokenizer.eos_token_id,
        pad_token_id=tokenizer.eos_token_id,
        # ❌ don't disable the KV cache; it's helpful on CPU
        # use_cache=True (default)
    )
    gen_ids = outputs[0][inputs["input_ids"].shape[1]:]
    return tokenizer.decode(gen_ids, skip_special_tokens=True).strip() or "(no answer)"