import { useState, useRef } from "react";
import Graph from "./Graph";
import TinySegmenter from "tiny-segmenter";

const segmenter = new TinySegmenter();

const SpeechRecognition =
  window.SpeechRecognition || window.webkitSpeechRecognition;

function App() {

  const [nodes, setNodes] = useState([]);
  const [connections, setConnections] = useState([]);
  const [selected, setSelected] = useState(null);

  const [input, setInput] = useState("");
  const [words, setWords] = useState([]);

  const recognitionRef = useRef(null);
  const prevNodeRef = useRef(null);

  const palette = [
    "#6C8AE4",
    "#8A7FE2",
    "#4DB6AC",
    "#F4A261",
    "#F28482"
  ];

  // -------------------------
  // 単語抽出
  // -------------------------

  const extractWords = (text) => {

    const segmented = segmenter.segment(text);

    const filtered = segmented.filter((word) => {

      return (
        word.length > 1 &&
        ![
          "です","ます","する","いる","ある",
          "それ","これ","こと","ため"
        ].includes(word)

      );

    });

    const unique = [...new Set(filtered)];

    setWords(unique);

    return unique;

  };

  // -------------------------
  // ノード追加
  // -------------------------

  const addWordNode = (word) => {

    setNodes((prev) => {

      const exists = prev.find((n) => n.text === word);

      if (exists) return prev;

      const newNode = {

        id: Date.now().toString(),
        text: word,
        color: palette[prev.length % palette.length]

      };

      if (prevNodeRef.current) {

        setConnections((c) => [

          ...c,
          {
            from: prevNodeRef.current.id,
            to: newNode.id
          }

        ]);

      }

      prevNodeRef.current = newNode;

      return [...prev, newNode];

    });

  };

  // -------------------------
  // 音声開始
  // -------------------------

  const startVoice = () => {

    if (!SpeechRecognition) {

      alert("このブラウザは音声入力に対応していません");
      return;

    }

    const recognition = new SpeechRecognition();

    recognition.lang = "ja-JP";
    recognition.continuous = true;
    recognition.interimResults = true;

    recognition.onresult = (event) => {

  for (let i = event.resultIndex; i < event.results.length; i++) {

    const result = event.results[i];

    // 確定した音声だけ処理
    if (!result.isFinal) continue;

    const transcript = result[0].transcript;

    setInput((prev) => prev + transcript);

    const extracted = extractWords(transcript);

    extracted.forEach((w) => addWordNode(w));

  }

};

    recognition.start();

    recognitionRef.current = recognition;

  };

  // -------------------------
  // 音声停止
  // -------------------------

  const stopVoice = () => {

    if (recognitionRef.current) {

      recognitionRef.current.stop();
      recognitionRef.current = null;

    }

  };

  // -------------------------
  // 手動送信
  // -------------------------

  const submitText = () => {

    if (!input) return;

    const extracted = extractWords(input);

    extracted.forEach((w) => addWordNode(w));

    setInput("");

  };

  // -------------------------
  // ノードクリック接続
  // -------------------------

  const handleSelect = (id) => {

    if (!selected) {

      setSelected(id);
      return;

    }

    if (selected === id) {

      setSelected(null);
      return;

    }

    setConnections((prev) => [

      ...prev,
      {
        from: selected,
        to: id
      }

    ]);

    setSelected(null);

  };

  return (

    <div style={{
      height: "100vh",
      display: "flex",
      flexDirection: "column"
    }}>

      {/* 上エリア */}

      <div style={{
        flex: 1,
        display: "flex",
        height: "100%"
      }}>

        {/* 単語一覧 */}

        <div style={{
          width: 250,
          borderRight: "1px solid #ddd",
          padding: 10,
          overflowY: "auto",
          height: "100%"
        }}>

          <h3 style={{
            position: "sticky",
            top: 0,
            background: "#fff"
          }}>
            単語
          </h3>

          {words.map((word, i) => (

            <div
              key={i}
              onClick={() => addWordNode(word)}
              style={{
                padding: 8,
                marginBottom: 6,
                background: "#f5f5f5",
                borderRadius: 6,
                cursor: "pointer"
              }}
            >

              {word}

            </div>

          ))}

        </div>

        {/* マップ */}

        <div style={{ flex: 1 }}>

          <Graph
            nodes={nodes}
            connections={connections}
            selected={selected}
            handleSelect={handleSelect}
          />

        </div>

      </div>

      {/* 入力エリア */}

      <div style={{
        borderTop: "1px solid #ddd",
        padding: 10,
        display: "flex"
      }}>

        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="話すか入力"
          style={{
            flex: 1,
            padding: 10,
            fontSize: 16
          }}
        />

        <button
          onClick={startVoice}
          style={{
            marginLeft: 10,
            padding: "10px 15px"
          }}
        >
          🎤 ON
        </button>

        <button
          onClick={stopVoice}
          style={{
            marginLeft: 10,
            padding: "10px 15px"
          }}
        >
          ■
        </button>

        <button
          onClick={submitText}
          style={{
            marginLeft: 10,
            padding: "10px 20px"
          }}
        >
          送信
        </button>

      </div>

    </div>

  );

}

export default App;