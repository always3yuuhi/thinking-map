import { useRef, useEffect } from "react";
import CytoscapeComponent from "react-cytoscapejs";
import cytoscape from "cytoscape";
import cola from "cytoscape-cola";

cytoscape.use(cola);

function Graph({ nodes = [], connections = [], selected, handleSelect }) {

  const cyRef = useRef(null);

  const elements = [];

  nodes.forEach((node) => {
    elements.push({
      data: {
        id: node.id,
        label: node.text,
        color: node.color
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

  // レイアウト制御
  useEffect(() => {

    if (!cyRef.current) return;

    const cy = cyRef.current;

    const layout = cy.layout({
      name: "cola",

      animate: true,
      randomize: false,

      nodeSpacing: 50,
      edgeLengthVal: 120,

      avoidOverlap: true,
      fit: true,
      padding: 50
    });

    layout.run();

  }, [nodes.length, connections.length]);

  return (

    <CytoscapeComponent

      cy={(cy) => {

        cyRef.current = cy;

        cy.on("tap", "node", (evt) => {

          const id = evt.target.id();

          if (handleSelect) handleSelect(id);

        });

      }}

      elements={elements}

      style={{
        width: "100%",
        height: "100%",
        background: "#f8f9fa"
      }}

      stylesheet={[
        {
          selector: "node",
          style: {

            label: "data(label)",
            shape: "roundrectangle",

            width: 160,
            height: 60,

            "text-valign": "center",
            "text-halign": "center",

            "text-wrap": "wrap",
            "text-max-width": 120,

            "background-color": "data(color)",
            color: "#fff",
            "font-size": 13

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