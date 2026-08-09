# Setting up the Obsidian MCP server for Claude Code

**Written:** 2026-08-09, after getting it working on this machine.
**Applies to:** Windows, Claude Code, Obsidian 1.13.x.

Lets Claude Code read, search, and edit this vault through Obsidian itself —
section-targeted reads, backlinks, tag listing, and in-place patches, rather
than treating notes as plain files.

## The short version

1. Obsidian → **Settings → Community plugins** → install and enable
   **"Local REST API with MCP"** (Adam Coddington). Use **v4.0.0–v5.x**.
2. **Settings → Local REST API** (main page) → turn on
   **Enable non-encrypted (HTTP) server**.
3. Copy the **API key** from that same page.
4. In a terminal: `setx OBSIDIAN_API_KEY "your-key-here"`
5. Add the server to `.mcp.json` (below).
6. Restart Claude Code. Obsidian must be running.

## The `.mcp.json` entry

```json
{
  "mcpServers": {
    "obsidian": {
      "type": "http",
      "url": "http://127.0.0.1:27123/mcp/",
      "headers": {
        "Authorization": "Bearer ${OBSIDIAN_API_KEY}"
      }
    }
  }
}
```

`.mcp.json` is **committed to this repo**, so the key must be a `${...}`
reference. Pasting the literal key would commit a secret.

## Things that cost time — read these

### There is no Obsidian plugin in the Claude Code marketplace
Enabling `obsidian@claude-plugins-official` in `~/.claude/settings.json` does
nothing: the official marketplace manifest has ~284 plugins and **none** of them
is Obsidian. (`install-counts-cache.json` lists such an id, but that file is a
popularity cache, not the manifest — it contains ids that aren't installable.)
The working integration is the **Obsidian plugin's own built-in MCP server**,
not a Claude Code plugin and not a third-party npm wrapper.

### Obsidian running ≠ MCP available
The desktop app exposes nothing by itself. The Local REST API plugin is what
opens the port.

### The enable toggle is on the main settings page, not Advanced
Plugin v5.1.0 rebuilt its settings tab. **Advanced settings** shows only the
*port numbers* (27124 HTTPS, 27123 HTTP). The actual
**Enable non-encrypted (HTTP) server** switch is on the **main** Local REST API
page. Its stored key is `enableInsecureServer`.

### Claude Code does not read `.env`
A project `.env` file is ignored by the harness. `${OBSIDIAN_API_KEY}` expands
from the **process environment**, so it has to be a real environment variable
(`setx`, then restart — `setx` only affects processes started afterwards).

### Use HTTP 27123, not HTTPS 27124
27124 is always-on but uses a **self-signed certificate** that fails strict TLS
validation, so MCP clients reject it. HTTP on 27123 is loopback-only
(`Binding host` = `127.0.0.1`), so nothing leaves the machine. To use HTTPS
instead you'd have to trust the cert or point `NODE_EXTRA_CA_CERTS` at it.

### Pin the plugin to v4–v5
v6.0 removes the markdown-patch 1.x wire format that section-targeted writes and
the document map depend on.

### It serves whichever vault is currently open
There is no vault-path setting — the API talks to Obsidian's open vault. Keep
this vault open, or Claude will be reading a different one. Worth remembering
given some notes here reference personal health context.

## Verifying it works

Plugin alive and on the right version (no key needed):

```bash
curl -sk https://127.0.0.1:27124/
```

Expect `"service": "Obsidian Local REST API"` and `"self": "5.1.0"`.

Is the HTTP port actually open?

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:27123/
```

`200` means yes; no response means `enableInsecureServer` is still off.

What's listening:

```bash
netstat -ano -p tcp | grep -E "27123|27124"
```

In Claude Code, `mcp__obsidian__vault_list` should return the vault root
(`Home.md`, `decisions/`, `ideas/`, `sessions/`, `guides/`).

## Security notes

- The plugin's `data.json` lives at
  `docs/vault/.obsidian/plugins/obsidian-local-rest-api/data.json` and contains
  the **API key and the TLS private key in plaintext**. Don't paste or dump it.
  (`docs/vault/.obsidian/` is gitignored, so it isn't committed.)
- To rotate both at once: **Settings → Local REST API → Reset all crypto**.
  It regenerates the certificate, key pair, *and* the API key — so re-run
  `setx OBSIDIAN_API_KEY "new-key"` and restart Claude Code afterwards.
- Screenshots of the settings page show the API key. Rotate if one gets shared.
- `.env` and `.env.*` are gitignored (added 2026-08-09) so a key left there
  isn't committed.

## Related

- [[ADR-007-peachy-design-system]] and the rest of the vault are what this
  server reads.
- Project MCP config lives in `.mcp.json` alongside `codegraph`.
