import { useState } from "react";
import { Bug, Eye } from "lucide-react";
import { aiPipelineLogs } from "../../data/mockData.js";
import PipelineTraceModal from "./PipelineTraceModal.jsx";

function statusClass(status) {
  if (status === "Success") return "ok";
  if (status === "Failed") return "danger";
  return "warning";
}

export default function AILogs({ embedded = false }) {
  const [selectedLog, setSelectedLog] = useState(null);

  return (
    <div className={embedded ? "ai-logs-embedded" : "page-stack"}>
      {!embedded ? <div className="page-toolbar">
        <div>
          <p className="eyebrow">AI Debugging</p>
          <h2>AI Logs / Pipeline Trace</h2>
          <p>Theo dõi retrieval, rule filtering, nutrition scoring, FoodyLLM generation và lỗi pipeline.</p>
        </div>
      </div> : null}

      <section className="panel">
        <div className="panel-heading">
          <h2><Bug size={20} /> Request logs</h2>
          <span className="chip active">Live mock</span>
        </div>
        <div className="table-scroll">
          <table className="data-table ai-log-table">
            <thead>
              <tr>
                <th>Request ID</th><th>User ID</th><th>Query</th><th>Request Type</th><th>Retrieved</th><th>Filtered</th><th>Final</th><th>Retrieval</th><th>Generation</th><th>Total</th><th>Status</th><th>Created At</th><th>Action</th>
              </tr>
            </thead>
            <tbody>
              {aiPipelineLogs.map((log) => (
                <tr key={log.requestId}>
                  <td><strong>{log.requestId}</strong></td>
                  <td>{log.userId}</td>
                  <td>{log.query}</td>
                  <td>{log.type}</td>
                  <td>{log.retrieved}</td>
                  <td>{log.filtered}</td>
                  <td>{log.final}</td>
                  <td>{log.retrievalLatency}</td>
                  <td>{log.generationLatency}</td>
                  <td>{log.totalLatency}</td>
                  <td><span className={`safety-badge ${statusClass(log.status)}`}>{log.status}</span></td>
                  <td>{log.createdAt}</td>
                  <td><button className="icon-link" onClick={() => setSelectedLog(log)} title="View Detail"><Eye size={17} /></button></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <PipelineTraceModal log={selectedLog} onClose={() => setSelectedLog(null)} />
    </div>
  );
}
