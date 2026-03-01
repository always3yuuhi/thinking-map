import React, { useState } from "react";
import "./App.css";

function App() {

  // 入力された文章
  const [text, setText] = useState("");

  // 抽出された単語
  const [words, setWords] = useState([]);

  // ===============================
  // 単語抽出（簡易版）
  // ===============================
  const extractWords = () => {

    // 空白や記号で分割
    const result = text
      .split(/[\s、。,.!?]+/)
      .filter((w) => w.length > 1);

    // 重複削除
    const unique = [...new Set(result)];

    setWords(unique);
  };

  return (

    // ===============================
    // アプリ全体
    // height:100vh にして
    // 画面全体を固定する
    // ===============================
    <div
      style={{
        display: "flex",
        height: "100vh",
        overflow: "hidden" // ★全体はスクロール禁止
      }}
    >

      {/* ===============================
          左：単語リスト
          ここだけスクロール可能にする
      =============================== */}
      <div
        style={{
          width: "220px",
          borderRight: "1px solid #ccc",
          padding: "10px",
          overflowY: "auto", // ★ここだけスクロール
          height: "100%"
        }}
      >
        <h3>単語</h3>

        {words.map((word, index) => (
          <div
            key={index}
            style={{
              padding: "4px",
              borderBottom: "1px solid #eee"
            }}
          >
            {word}
          </div>
        ))}
      </div>

      {/* ===============================
          右側メイン
          マップ + 入力欄
          ここはスクロールしない
      =============================== */}
      <div
        style={{
          flex: 1,
          display: "flex",
          flexDirection: "column",
          padding: "10px"
        }}
      >

        {/* マップエリア */}
        <div
          style={{
            flex: 1,
            border: "1px solid #ccc",
            marginBottom: "10px",
            display: "flex",
            alignItems: "center",
            justifyContent: "center"
          }}
        >
          Thinking Map（ここにノード表示）
        </div>

        {/* 入力エリア */}
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="文章を入力してください"
          style={{
            width: "100%",
            height: "120px",
            marginBottom: "10px"
          }}
        />

        <button onClick={extractWords}>
          単語抽出
        </button>

      </div>
    </div>
  );
}

export default App;