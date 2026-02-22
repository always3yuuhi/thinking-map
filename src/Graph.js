import { useRef } from "react";
import CytoscapeComponent from "react-cytoscapejs";

function Graph({ nodes, centerId, setCenterId }) {
  const cyRef = useRef(null);
  const elements = [];

  nodes.forEach((node, index) => {
    elements.push({
      data: { id: index.toString(), label: node }
    });

    if (index.toString() !== centerId) {
      elements.push({
        data: {
          source: centerId,
          target: index.toString()
        }
      });
    }
  });

  const handleFit = () => {
    if (cyRef.current) {
      cyRef.current.fit();
    }
  };

  return (
    <div>
      <button onClick={handleFit} style={{ marginBottom: 10 }}>
        全体表示
      </button>

      <CytoscapeComponent
        cy={(cy) => {
          cyRef.current = cy;

          cy.on("tap", "node", (evt) => {
            const id = evt.target.id();
            setCenterId(id);
          });
        }}
        elements={elements}
        style={{ width: "800px", height: "500px", border: "1px solid #ccc" }}
        layout={{ name: "cose" }}
        stylesheet={[
          {
            selector: "node",
            style: {
              label: "data(label)",
              "text-wrap": "wrap",
              "text-max-width": 120,
              width: 150,
              height: 60,
              "text-valign": "center",
              "text-halign": "center",
              "background-color": "#4CAF50",
              color: "#fff",
              "font-size": 12
            }
          },
          {
            selector: `node[id = "${centerId}"]`,
            style: {
              "background-color": "#E53935"
            }
          },
          {
            selector: "edge",
            style: {
              width: 2,
              "line-color": "#999"
            }
          }
        ]}
      />
    </div>
  );
}

export default Graph;