import React, { useState } from "react";
import axios from "axios";

function App() {
  const [name, setName] = useState("");

  const submit = async () => {
    await axios.post(process.env.REACT_APP_API_URL + "/submit", {
      name: name
    });
    alert("Submitted!");
  };

  return (
    <div style={{ padding: "40px" }}>
      <h2>Mini GCP DevOps App</h2>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Enter name"
      />
      <button onClick={submit}>Submit</button>
    </div>
  );
}

export default App;