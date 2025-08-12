import { useState } from "react" 

const LlmPrompt = () => {
    // State variables for prompt, answer and when API is loading 
    const [prompt, setPrompt] = useState("");
    const [answer, setAnswer] = useState("");
    const [loading, setLoading] = useState(false);
    
    const API_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:8080";
    
    // Function to handle form submission and fetch the answer from the API
    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setAnswer("");

        try {
            const resp = await fetch(`${API_URL}/generate`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({prompt}),
            });
        if (!resp.ok) {
            const text = await resp.text();
            throw new Error(`${resp.status}, ${text}`)         
        }
            const data = await resp.json();
            setAnswer(data.output ?? "(no output)")
        } catch (err) {
            setAnswer(`Error: ${err.message}`);
        } finally {
            setLoading(false);
        }
    }

    return (
        <div>
            <form onSubmit={handleSubmit}>
                <textarea 
                 rows={4}
                 value={prompt}
                 onChange={(e) => setPrompt(e.target.value)}
                 placeholder="Ask me anything..."
                 />
                <button type="submit" disabled={loading || !prompt.trim()}>
                    {loading ? "Loading..." : "Submit"}
                </button>
            </form>
            

            {answer && (
                <section>  
                <h1>LLm Here</h1>
                <pre>{answer}</pre>
                 </section>
            )}

        </div>
    )
}


export default LlmPrompt;
