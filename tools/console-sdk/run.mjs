// run.mjs : one Console worker task through the Claude Agent SDK. His Max plan's monthly API credits cover the Agent SDK and
// the API, but NOT Claude Code, so the worker runs here instead of through the claude command (2026-10-17).
// tools/console-worker.sh calls it with CW_R, CW_S, CW_M (folders), CW_TASK, CW_PROMPT_FILE, CW_RULES, CW_ALLOW (JSON list),
// CW_BUDGET, plus ANTHROPIC_API_KEY (read from his Windows variable, never printed) and ANTHROPIC_CUSTOM_HEADERS (his workspace).
// It prints one JSON line: result, total_cost_usd, terminal_reason, subtype.
import { query } from '@anthropic-ai/claude-agent-sdk';
import { readFileSync } from 'fs';
const e = process.env;
const out = { result: '', total_cost_usd: 0, terminal_reason: '', subtype: '' };
try {
  const prompt = 'Your task id is ' + e.CW_TASK + '. ' + readFileSync(e.CW_PROMPT_FILE, 'utf8');
  for await (const m of query({ prompt, options: {
    model: 'sonnet', cwd: e.CW_R, additionalDirectories: [e.CW_S, e.CW_M],
    systemPrompt: readFileSync(e.CW_RULES, 'utf8'),
    permissionMode: 'dontAsk', allowedTools: JSON.parse(e.CW_ALLOW), disallowedTools: ['WebFetch', 'WebSearch'],
    maxBudgetUsd: Number(e.CW_BUDGET), settingSources: [], mcpServers: {}, strictMcpConfig: true, persistSession: false,

    env: { ...e }
  } })) {
    if (m.type === 'result') {
      out.result = m.result || (m.errors || []).join('; ');
      out.total_cost_usd = m.total_cost_usd || 0; out.terminal_reason = m.terminal_reason || ''; out.subtype = m.subtype || '';
    }
  }
} catch (err) {
  out.result = 'SDK error: ' + String((err && err.message) || err).slice(0, 500);
  if (!out.terminal_reason) out.terminal_reason = 'api_error';
}
console.log(JSON.stringify(out));
