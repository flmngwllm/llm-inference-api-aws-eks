import os, torch
from transformers import AutoTokenizer, AutoModelForCausalLM

# Keep your original env var name / default
MODEL_NAME = os.getenv("MODEL_NAME", "Qwen/Qwen2.5-0.5B-Instruct")

# fast tokenizer + lower peak RAM on load
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME, use_fast=True)
model = AutoModelForCausalLM.from_pretrained(
    MODEL_NAME,
    torch_dtype=torch.float16,     # halves weight memory, fine on CPU for this size
    low_cpu_mem_usage=True,        # reduces load-time peak RAM
)
model.eval()


if tokenizer.pad_token_id is None:
    tokenizer.pad_token = tokenizer.eos_token

# Optional env dials 
MAX_INPUT_TOKENS = int(os.getenv("MAX_INPUT_TOKENS", "1024"))
MAX_NEW_TOKENS   = int(os.getenv("MAX_NEW_TOKENS", "256"))
DO_SAMPLE        = os.getenv("DO_SAMPLE", "true").lower() == "true"
TEMPERATURE      = float(os.getenv("TEMPERATURE", "0.7"))
TOP_P            = float(os.getenv("TOP_P", "0.95"))

@torch.no_grad()
def generate_text(prompt: str) -> str:
    # instruction following
    messages = [{"role": "user", "content": prompt}]
    templated = tokenizer.apply_chat_template(
        messages, tokenize=False, add_generation_prompt=True
    )
    inputs = tokenizer(
        templated,
        return_tensors="pt",
        truncation=True,
        max_length=MAX_INPUT_TOKENS,  # keeps memory in check
    )
    outputs = model.generate(
        **inputs,
        max_new_tokens=MAX_NEW_TOKENS,
        do_sample=DO_SAMPLE,
        temperature=TEMPERATURE,
        top_p=TOP_P,
        eos_token_id=tokenizer.eos_token_id,
        pad_token_id=tokenizer.eos_token_id,
        use_cache=False,
    )
    # Decode only the newly generated tokens (strip the prompt/template)
    gen_ids = outputs[0][inputs["input_ids"].shape[1]:]
    return tokenizer.decode(gen_ids, skip_special_tokens=True).strip()