import { X } from "lucide-react";
import { pipelineTrace } from "../../data/mockData.js";

export default function PipelineTraceModal({ log, onClose }) {
  if (!log) return null;

  return (
    <div className="modal-backdrop">
      <aside className="panel pipeline-modal" role="dialog" aria-modal="true" aria-label="Pipeline trace detail">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">Pipeline Trace</p>
            <h2>{log.requestId}</h2>
            <p>{log.query}</p>
          </div>
          <button className="icon-link" onClick={onClose} aria-label="Đóng trace"><X size={18} /></button>
        </div>
        <div className="pipeline-trace-list">
          {pipelineTrace.map((step) => (
            <div className="pipeline-step" key={step.step}>
              <span className="status-dot">{step.status}</span>
              <div>
                <strong>{step.step}</strong>
                <p>{step.detail}</p>
              </div>
            </div>
          ))}
          {log.status === "Failed" ? (
            <div className="warning-panel mini">
              <span>Error message: Không còn candidate sau allergy filter cho truy vấn keto dessert không hạt.</span>
            </div>
          ) : null}
        </div>
      </aside>
    </div>
  );
}
