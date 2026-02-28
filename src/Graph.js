import { useRef, useEffect } from "react";
import CytoscapeComponent from "react-cytoscapejs";
import cytoscape from "cytoscape";
import cola from "cytoscape-cola";

cytoscape.use(cola);

function Graph({ nodes = [], connections = [], selected, handleSelect }) {

  const cyRef = useRef(null);

  /*
  Cytoscape elements生成
  */

  const elements = [];

  nodes.forEach((node) => {

    elements.push({

      data: {
        id: node.id,
        label: `${node.text} (${node.frequency})`,
        color: node.color,
        frequency: node.frequency
      }

    });

  });

  connections.forEach((conn, index) => {

    elements.push({

      data: {
        id: "e" + index,
        source: conn.from,
        target: conn.to
      }

    });

  });

  /*
  レイアウト
  */

  useEffect(() => {

    if (!cyRef.current) return;

    const layout = cyRef.current.layout({

      name: "cola",
      animate: true,

      nodeSpacing: 20,
      edgeLengthVal: 80,

      gravity: 0.8,

      infinite: true,
      convergenceThreshold: 0.03,
      avoidOverlap: true

    });

    layout.run();

  }, [nodes, connections]);

  return (

    <CytoscapeComponent

      cy={(cy) => {

        cyRef.current = cy;

        cy.on("tap", "node", (evt) => {

          const id = evt.target.id();

          handleSelect?.(id);

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

            /*
            frequencyに応じてサイズ変更
            */

            width: "mapData(frequency, 1, 10, 120, 240)",
            height: "mapData(frequency, 1, 10, 60, 120)",

            shape: "roundrectangle",

            "text-wrap": "wrap",
            "text-max-width": 120,

            "text-valign": "center",
            "text-halign": "center",

            "background-color": "data(color)",

            color: "#fff"

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
          selector: `node[id = "${selected}"]`,
          style: {

            "border-width": 3,
            "border-color": "#333"

          }
        }

      ]}

    />

  );

}

export default Graph;