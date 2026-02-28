import { useState, useRef, useEffect } from "react";
import Graph from "./Graph";
import TinySegmenter from "tiny-segmenter";

/*
日本語単語分割
*/
const segmenter = new TinySegmenter();

function App() {

  /*
  =========================
  Thinking Map データ
  =========================
  */

  const [nodes, setNodes] = useState([]);
  const [connections, setConnections] = useState([]);

  const [selected, setSelected] = useState(null);

  /*
  思考の流れ
  */

  const [prevNode, setPrevNode] = useState(null);

  /*
  入力
  */

  const [input, setInput] = useState("");
  const [words, setWords] = useState([]);

  /*
  音声認識
  */

  const recognitionRef = useRef(null);

  /*
  ノード色
  */

  const palette = [
    "#6C8AE4",
    "#8A7FE2",
    "#4DB6AC",
    "#F4A261",
    "#F28482"
  ];

  /*
  =========================
  音声認識初期化
  =========================
  */

  useEffect(() => {

    const SpeechRecognition =
      window.SpeechRecognition || window.webkitSpeechRecognition;

    if (!SpeechRecognition) {

      alert("音声認識が使えません");

      return;

    }

    const recognition = new SpeechRecognition();

    recognition.lang = "ja-JP";
    recognition.continuous = true;
    recognition.interimResults = true;

    recognition.onresult = (event) => {

      let transcript = "";

      for (let i = event.resultIndex; i < event.results.length; i++) {

        transcript += event.results[i][0].transcript;

      }

      setInput(transcript);

      extractWords(transcript);

    };

    recognitionRef.current = recognition;

  }, []);

  /*
  =========================
  音声操作
  =========================
  */

  const startVoice = () => {

    recognitionRef.current?.start();

  };

  const stopVoice = () => {

    recognitionRef.current?.stop();

  };

  /*
  =========================
  単語抽出
  =========================
  */

  const extractWords = (text) => {

    const segmented = segmenter.segment(text);

    const filtered = segmented.filter((word) => {

      return (

        word.length > 1 &&

        ![
          "は","が","を","に","で","と","も","の","へ","や",
          "です","ます","する","いる","ある"
        ].includes(word)

      );

    });

    const unique = [...new Set(filtered)];

    setWords(unique);

    /*
    自動Thinking Map生成
    */

    unique.forEach(word => addWordNode(word));

  };

  /*
  =========================
  ノード追加
  =========================
  */

  const addWordNode = (word) => {

    /*
    同じ単語ノード確認
    */

    const existing = nodes.find(n => n.text === word);

    /*
    既存ノードの場合
    */

    if (existing) {

      /*
      frequency 増加
      */

      setNodes(prev => prev.map(node => {

        if (node.id === existing.id) {

          return {

            ...node,
            frequency: node.frequency + 1

          };

        }

        return node;

      }));

      /*
      思考接続
      */

      if (prevNode && prevNode.id !== existing.id) {

        const edgeExists = connections.some(
          c => c.from === prevNode.id && c.to === existing.id
        );

        if (!edgeExists) {

          setConnections(prev => [

            ...prev,
            {
              from: prevNode.id,
              to: existing.id
            }

          ]);

        }

      }

      setPrevNode(existing);

      return;

    }

    /*
    新規ノード
    */

    const newNode = {

      id: Date.now().toString(),
      text: word,

      /*
      初期頻度
      */

      frequency: 1,

      color: palette[nodes.length % palette.length]

    };

    setNodes(prev => [...prev, newNode]);

    /*
    思考の流れ接続
    */

    if (prevNode) {

      const edgeExists = connections.some(
        c => c.from === prevNode.id && c.to === newNode.id
      );

      if (!edgeExists) {

        setConnections(prev => [

          ...prev,
          {
            from: prevNode.id,
            to: newNode.id
          }

        ]);

      }

    }

    setPrevNode(newNode);

  };

  /*
  =========================
  手動ノード接続
  =========================
  */

  const handleSelect = (id) => {

    if (!selected) {

      setSelected(id);
      return;

    }

    if (selected === id) {

      setSelected(null);
      return;

    }

    setConnections(prev => [

      ...prev,
      {
        from: selected,
        to: id
      }

    ]);

    setSelected(null);

  };

  /*
  =========================
  入力送信
  =========================
  */

  const submitText = () => {

    if (!input) return;

    extractWords(input);

    setInput("");

  };

  /*
  =========================
  UI
  =========================
  */

  return (

    <div style={{
      height: "100vh",
      display: "flex",
      flexDirection: "column"
    }}>

      <div style={{ flex: 1, display: "flex" }}>

        {/* 単語一覧 */}

        <div style={{
          width: 250,
          borderRight: "1px solid #ddd",
          padding: 10,
          overflow: "auto"
        }}>

          <h3>単語</h3>

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

        {/* グラフ */}

        <div style={{ flex: 1 }}>

          <Graph
            nodes={nodes}
            connections={connections}
            selected={selected}
            handleSelect={handleSelect}
          />

        </div>

      </div>

      {/* 入力 */}

      <div style={{
        borderTop: "1px solid #ddd",
        padding: 10,
        display: "flex"
      }}>

        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          style={{
            flex: 1,
            padding: 10,
            fontSize: 16
          }}
        />

        <button onClick={submitText} style={{ marginLeft: 10 }}>
          送信
        </button>

        <button onClick={startVoice} style={{ marginLeft: 10 }}>
          🎤
        </button>

        <button onClick={stopVoice} style={{ marginLeft: 10 }}>
          ⏹
        </button>

      </div>

    </div>

  );

}

export default App;