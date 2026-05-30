#!/usr/bin/env bash
# =============================================================================
#  setup-node.sh — OPN Chain Full Node (Testnet)
#  Optimized for: NVMe SSD, RocksDB, Tendermint P2P tuning, UFW hardening
#  Reference: https://iopn.gitbook.io/developer-docs/node-overview
#  Run as root on Ubuntu 22.04
# =============================================================================
set -euo pipefail

# ── Variables — edit before running ──────────────────────────────────────────
NGINX_IP="127.0.0.1"          # IP of Nginx (same server = 127.0.0.1)
OPN_VERSION="latest"          # check https://github.com/iopnet for latest release
OPN_HOME="$HOME/.opn"
CHAIN_ID="opn_984-1"
# ─────────────────────────────────────────────────────────────────────────────

echo "============================================"
echo " OPN Chain Testnet Node — Setup"
echo "============================================"

# ── 1. System dependencies ────────────────────────────────────────────────────
echo "[1/8] Installing dependencies..."
apt-get update -q
apt-get install -y -q \
    build-essential curl git jq lz4 unzip wget \
    librocksdb-dev libsnappy-dev liblz4-dev \
    ufw

# ── 2. Firewall ───────────────────────────────────────────────────────────────
echo "[2/8] Configuring UFW..."

ufw allow 22/tcp     comment "SSH"
ufw allow 80/tcp     comment "HTTP"
ufw allow 443/tcp    comment "HTTPS"
ufw allow 26656/tcp  comment "OPN P2P"

# Port 26657 (RPC) — only accessible from Nginx on this machine
ufw deny 26657/tcp
ufw allow from "$NGINX_IP" to any port 26657 proto tcp comment "OPN RPC (Nginx only)"

# Port 8545 (EVM RPC) — only from Nginx
ufw deny 8545/tcp
ufw allow from "$NGINX_IP" to any port 8545 proto tcp comment "OPN EVM RPC (Nginx only)"

ufw --force enable
echo "    UFW status:"
ufw status numbered | grep -E "26656|26657|8545" || true

# ── 3. Download OPN binary ────────────────────────────────────────────────────
echo "[3/8] Downloading OPN Chain binary..."
# Check official release URL at: https://iopn.gitbook.io/developer-docs/node-overview
# Replace the URL below with the actual binary once confirmed from official docs
#
# Example (update URL to real release):
# wget -q https://github.com/iopnet/opn-chain/releases/download/v1.0.0/opnd-linux-amd64 -O /usr/local/bin/opnd
# chmod +x /usr/local/bin/opnd
#
echo "    ⚠  ACTION REQUIRED: Download the OPN binary manually."
echo "    Check: https://iopn.gitbook.io/developer-docs/node-overview"
echo "    Then place binary at: /usr/local/bin/opnd"
echo "    Run: chmod +x /usr/local/bin/opnd"
echo ""

# ── 4. Initialize node ────────────────────────────────────────────────────────
echo "[4/8] Initializing node (skip if already done)..."
if command -v opnd >/dev/null 2>&1 && [ ! -d "$OPN_HOME/config" ]; then
    opnd init "opn-infra-node" --chain-id "$CHAIN_ID" --home "$OPN_HOME"
    echo "    Node initialized at $OPN_HOME"
elif [ -d "$OPN_HOME/config" ]; then
    echo "    Node already initialized — skipping"
else
    echo "    Skipped — opnd binary not found (complete step 3 first)"
fi

# ── 5. Apply performance optimizations ───────────────────────────────────────
echo "[5/8] Applying Tendermint + RocksDB optimizations..."

CONFIG="$OPN_HOME/config/config.toml"
APP_CONFIG="$OPN_HOME/config/app.toml"

if [ -f "$CONFIG" ]; then
    # RocksDB — better concurrent EVM state writes vs default goleveldb
    sed -i 's/^db_backend = .*/db_backend = "rocksdb"/' "$CONFIG"

    # P2P bandwidth — maximize gossip sync speed between validators
    sed -i 's/^send_rate = .*/send_rate = 5120000/' "$CONFIG"
    sed -i 's/^recv_rate = .*/recv_rate = 5120000/' "$CONFIG"

    # RPC — listen on localhost only (Nginx proxies externally)
    sed -i 's|^laddr = "tcp://0.0.0.0:26657"|laddr = "tcp://127.0.0.1:26657"|' "$CONFIG"

    # Prometheus metrics (optional — useful for monitoring)
    sed -i 's/^prometheus = false/prometheus = true/' "$CONFIG"

    echo "    config.toml updated"
fi

if [ -f "$APP_CONFIG" ]; then
    # EVM JSON-RPC — localhost only
    sed -i 's|^address = "0.0.0.0:8545"|address = "127.0.0.1:8545"|' "$APP_CONFIG"
    echo "    app.toml updated"
fi

# ── 6. Key file permissions ───────────────────────────────────────────────────
echo "[6/8] Hardening key file permissions..."
if [ -d "$OPN_HOME/config" ]; then
    chmod 600 "$OPN_HOME/config/"*_key.json 2>/dev/null && \
        echo "    Private keys locked (chmod 600)" || \
        echo "    No key files found yet — run after init"
fi

# ── 7. NVMe TRIM (prevent SSD performance degradation) ───────────────────────
echo "[7/8] Enabling periodic SSD TRIM..."
systemctl enable fstrim.timer
systemctl start  fstrim.timer
echo "    fstrim.timer enabled"

# ── 8. Systemd service ───────────────────────────────────────────────────────
echo "[8/8] Creating systemd service..."

cat > /etc/systemd/system/opnd.service << SVCEOF
[Unit]
Description=OPN Chain Testnet Node
After=network-online.target
Wants=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/opnd start \
    --home ${OPN_HOME} \
    --chain-id ${CHAIN_ID}
Restart=on-failure
RestartSec=5s
LimitNOFILE=65536
LimitNPROC=65536

StandardOutput=journal
StandardError=journal
SyslogIdentifier=opnd

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable opnd

echo ""
echo "============================================"
echo " Setup complete."
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Place OPN binary at /usr/local/bin/opnd"
echo "  2. Download genesis.json from official docs"
echo "  3. Add seed nodes to $OPN_HOME/config/config.toml"
echo "  4. systemctl start opnd"
echo "  5. journalctl -fu opnd  (watch sync progress)"
echo ""
echo "Verify node is syncing:"
echo "  curl http://127.0.0.1:26657/status | jq .result.sync_info"
echo ""
echo "Ports open:"
echo "  26656  → P2P (public)"
echo "  26657  → RPC (127.0.0.1 only → Nginx)"
echo "  8545   → EVM RPC (127.0.0.1 only → Nginx)"
