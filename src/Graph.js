import { useRef, useEffect } from "react";
import CytoscapeComponent from "react-cytoscapejs";
import cytoscape from "cytoscape";
import cola from "cytoscape-cola";

// colaレイアウトを有効化
cytoscape.use(cola);

function Graph({ nodes, connections, selected, handleSelect }) {
  const cyRef = useRef(null);

  // =============================
  // ノード・エッジ要素生成
  // =============================
  const elements = [];

  // ノード生成
  nodes.forEach((node) => {
    elements.push({
      data: {
        id: node.id,          // 一意ID（string）
        label: node.text,     // 表示テキスト
        color: node.color     // 背景色
      }
    });
  });

  // 接続（エッジ）生成
  connections.forEach((conn, index) => {
    elements.push({
      data: {
        id: "e" + index,
        source: conn.from,
        target: conn.to
      }
    });
  });

  // =============================
  // ノードや接続が変わるたびに
  // 物理レイアウトを再実行
  // =============================
  useEffect(() => {
    if (!cyRef.current) return;

    const layout = cyRef.current.layout({
      name: "cola",

      animate: true,          // アニメーションあり
      refresh: 2,             // 再描画頻度（小さいほど滑らか）
      randomize: false,       // 追加時にランダム化しない

      // ===== 距離感を調整する主要パラメータ =====
      nodeSpacing: 20,        // ノード同士の最低距離（小さくすると近づく）
      edgeLengthVal: 80,     // 接続線の理想長さ（短くすると締まる）
      gravity: 0.8,           // 中心に引き寄せる力（大きいとまとまる）

      // ===== 安定性調整 =====
      infinite: true,         // 常時物理ON
      convergenceThreshold: 0.03, // 小さいほど揺れが少ない
      avoidOverlap: true      // ノード重なり防止
    });

    layout.run();
  }, [nodes, connections]);

  return (
    <div>
      <CytoscapeComponent
        cy={(cy) => {
          cyRef.current = cy;

          // ノードクリックで選択
          cy.on("tap", "node", (evt) => {
            const id = evt.target.id();
            handleSelect(id);
          });
        }}
        elements={elements}
        style={{
          width: "100%",
          height: "500px",
          background: "#f8f9fa"
        }}
        stylesheet={[
          {
            selector: "node",
            style: {
              label: "data(label)",
              "text-wrap": "wrap",
              "text-max-width": 120,

              width: 160,
              height: 60,

              "text-valign": "center",
              "text-halign": "center",

              "background-color": "data(color)",
              color: "#fff",

              "font-size": 13,
              "font-weight": 600
            }
          },
          {
            selector: "edge",
            style: {
              width: 2,
              "line-color": "#bbb",
              "curve-style": "bezier"
            }
          },
          {
            // 選択ノードを少し拡大
            selector: `node[id = "${selected}"]`,
            style: {
              width: 180,
              height: 70,
              "border-width": 3,
              "border-color": "#333"
            }
          }
        ]}
      />
    </div>
  );
}

export default Graph;