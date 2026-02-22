import Graph from "./Graph";
import { useState } from "react";


function App() {
  const [nodes, setNodes] = useState([]);
  const [input, setInput] = useState("");
  const [centerId, setCenterId] = useState("0");

  const addNode = () => {
    if (!input) return;
    setNodes([...nodes, input]);
    setInput("");
  };

  const resetNodes = () => {
  setNodes([]);
};

  return (
    <div style={{ padding: 40 }}>
      <h1>Thinking Map</h1>

      <input
        value={input}
        onChange={(e) => setInput(e.target.value)}
        placeholder="発言を入力"
        style={{ width: 300 }}
      />

      <button onClick={addNode}>追加</button>
      <button onClick={resetNodes} style={{ marginLeft: 10 }}>
  リセット
</button>

<Graph nodes={nodes} centerId={centerId} setCenterId={setCenterId} />
    </div>
  );
}

export default App;