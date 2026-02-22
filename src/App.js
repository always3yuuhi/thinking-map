import Graph from "./Graph";
import { useState } from "react";
import TinySegmenter from "tiny-segmenter";

const segmenter = new TinySegmenter();

function App() {
  const [nodes, setNodes] = useState([]);
  const [input, setInput] = useState("");
  const [selected, setSelected] = useState(null);
  const [connections, setConnections] = useState([]);
  const [textInput, setTextInput] = useState("");
  const [extractedWords, setExtractedWords] = useState([]);

  const palette = [
    "#6C8AE4",
    "#8A7FE2",
    "#4DB6AC",
    "#F4A261",
    "#F28482"
  ];

  // ==========================
  // 単語抽出（細かく分解）
  // ==========================
  const extractWords = () => {
    const words = segmenter.segment(textInput);

    const filtered = words.filter((word) => {
      return (
        word.length > 1 &&
        !["は","が","を","に","で","と","も","の","へ","や","か","です","ます","する","いる","ある"].includes(word)
      );
    });

    const unique = [...new Set(filtered)];
    setExtractedWords(unique);
  };

  const addWordNode = (word) => {
    setNodes((prev) => [
      ...prev,
      {
        id: Date.now().toString(),
        text: word,
        color: palette[prev.length % palette.length]
      }
    ]);
  };

  const addNode = () => {
    if (!input) return;

    setNodes((prev) => [
      ...prev,
      {
        id: Date.now().toString(),
        text: input,
        color: palette[prev.length % palette.length]
      }
    ]);

    setInput("");
  };

  const handleSelect = (id) => {
    if (!selected) {
      setSelected(id);
    } else if (selected === id) {
      setSelected(null);
    } else {
      setConnections((prev) => [
        ...prev,
        { from: selected, to: id }
      ]);
      setSelected(null);
    }
  };

  const resetNodes = () => {
    setNodes([]);
    setConnections([]);
    setSelected(null);
  };

  return (
    <div style={{ padding: 20 }}>
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

      <div style={{ marginTop: 30 }}>
        <textarea
          value={textInput}
          onChange={(e) => setTextInput(e.target.value)}
          placeholder="文章を入力"
          style={{ width: "100%", height: 120 }}
        />

        <button onClick={extractWords} style={{ marginTop: 10 }}>
          単語抽出
        </button>

        <div style={{ marginTop: 10 }}>
          {extractedWords.map((word, index) => (
            <button
              key={index}
              onClick={() => addWordNode(word)}
              style={{ margin: 5 }}
            >
              {word}
            </button>
          ))}
        </div>
      </div>

      <Graph
        nodes={nodes}
        connections={connections}
        selected={selected}
        handleSelect={handleSelect}
      />
    </div>
  );
}

export default App;