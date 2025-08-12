from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model_name = "distilgpt2"

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, torch_dtype=torch.float32)
model.eval()

if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

@torch.no_grad()
def generate_text(prompt: str) -> str:
    inputs = tokenizer(prompt, return_tensors="pt", truncation=True, max_length=512)
    outputs = model.generate(**inputs, 
        max_new_tokens=100,
        pad_token_id=tokenizer.eos_token_id,
        do_sample=False,          # set True for sampling
        temperature=0.8,          # used only if do_sample=True
        top_p=0.9      
        )  
    return tokenizer.decode(outputs[0], skip_special_tokens=True)