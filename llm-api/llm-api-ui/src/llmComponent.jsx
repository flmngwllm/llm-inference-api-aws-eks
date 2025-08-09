import React, { useState } from "react" 

const LlmComponent = () => {
    // State variables for prompt, answer and when API is loading 
    const [prompt, setPrompt] = useState("")
    const [answer, setAnswer] = useState("")
    const [loading, setLoading] = useState(false)
    API_URL = ""
    
    // Function to handle form submission and fetch the answer from the API
    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setAnswer("");

        try {
            const resp = await fetch(`${API_URL}/generate`, {
                method: "POST",
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({prompt})
            });
        if (!resp.ok) {
            const text = await resp.text();
                throw new Error(`${resp.status}, ${text}`)         
        }
            const data = await resp.json();
            setAnswer(data.output ?? "No answer provided");
        } catch (err) {
            setAnswer(`Error: ${err.message}`);
        } finally {
            setLoading(false);
        }
    }

    return (
        <div>
            <h1>LLm Here</h1>

        </div>
    )
}


export default LlmComponent;
