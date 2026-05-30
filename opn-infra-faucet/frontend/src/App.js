import { useState, useEffect, useCallback } from "react";
import { ethers } from "ethers";
import {
  TOKEN_ADDRESS,
  FAUCET_ADDRESS,
  CHAIN_ID,
  CHAIN_ID_HEX,
  NETWORK,
  TOKEN_ABI,
  FAUCET_ABI,
  DEFAULT_DRIP_AMOUNT,
} from "./config";
import "./App.css";

const STATUS = {
  IDLE: "idle",
  WAITING_SIGNATURE: "waiting_signature",
  PENDING: "pending",
  SUCCESS: "success",
  ERROR: "error",
};

function formatTokens(value, decimals = 18) {
  return parseFloat(ethers.formatUnits(value, decimals)).toLocaleString(undefined, {
    maximumFractionDigits: 4,
  });
}

function formatCountdown(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

function App() {
  const [account, setAccount] = useState(null);
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [chainOk, setChainOk] = useState(false);
  const [faucetBalance, setFaucetBalance] = useState(null);
  const [userBalance, setUserBalance] = useState(null);
  const [tokenSymbol, setTokenSymbol] = useState("OPIT");
  const [dripAmount, setDripAmount] = useState(DEFAULT_DRIP_AMOUNT);
  const [cooldown, setCooldown] = useState(0);
  const [status, setStatus] = useState(STATUS.IDLE);
  const [errorMsg, setErrorMsg] = useState("");
  const [txHash, setTxHash] = useState("");

  const loadBalances = useCallback(async (prov, addr) => {
    if (!prov || !addr) return;

    const token = new ethers.Contract(TOKEN_ADDRESS, TOKEN_ABI, prov);
    const faucet = new ethers.Contract(FAUCET_ADDRESS, FAUCET_ABI, prov);

    const [fBal, uBal, symbol, remaining, allowed] = await Promise.all([
      faucet.getFaucetBalance(),
      token.balanceOf(addr),
      token.symbol(),
      faucet.cooldownRemaining(addr),
      faucet.amountAllowed(),
    ]);

    setFaucetBalance(fBal);
    setUserBalance(uBal);
    setTokenSymbol(symbol);
    setCooldown(Number(remaining));
    setDripAmount(allowed);
  }, []);

  const checkChain = useCallback(async () => {
    if (!window.ethereum) return false;
    const chainId = await window.ethereum.request({ method: "eth_chainId" });
    const ok = parseInt(chainId, 16) === CHAIN_ID;
    setChainOk(ok);
    return ok;
  }, []);

  const switchNetwork = async () => {
    try {
      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: CHAIN_ID_HEX }],
      });
      setChainOk(true);
    } catch (switchError) {
      if (switchError.code === 4902) {
        await window.ethereum.request({
          method: "wallet_addEthereumChain",
          params: [NETWORK],
        });
        setChainOk(true);
      } else {
        throw switchError;
      }
    }
  };

  const connectWallet = async () => {
    if (!window.ethereum) {
      setErrorMsg("MetaMask not detected. Please install MetaMask.");
      setStatus(STATUS.ERROR);
      return;
    }

    try {
      setStatus(STATUS.IDLE);
      setErrorMsg("");

      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });

      const prov = new ethers.BrowserProvider(window.ethereum);
      const sig = await prov.getSigner();
      const addr = accounts[0];

      setProvider(prov);
      setSigner(sig);
      setAccount(addr);

      const ok = await checkChain();
      if (!ok) {
        await switchNetwork();
      }

      await loadBalances(prov, addr);
    } catch (err) {
      setErrorMsg(err.message || "Failed to connect wallet");
      setStatus(STATUS.ERROR);
    }
  };

  const requestTokens = async () => {
    if (!signer || !account) return;

    try {
      setStatus(STATUS.WAITING_SIGNATURE);
      setErrorMsg("");
      setTxHash("");

      const faucet = new ethers.Contract(FAUCET_ADDRESS, FAUCET_ABI, signer);
      const tx = await faucet.requestTokens();

      setStatus(STATUS.PENDING);
      setTxHash(tx.hash);

      await tx.wait();
      setStatus(STATUS.SUCCESS);
      await loadBalances(provider, account);
    } catch (err) {
      const msg =
        err.reason ||
        err.shortMessage ||
        err.message ||
        "Transaction failed";
      setErrorMsg(msg);
      setStatus(STATUS.ERROR);
    }
  };

  useEffect(() => {
    if (!window.ethereum) return;

    const onAccountsChanged = (accounts) => {
      if (accounts.length === 0) {
        setAccount(null);
        setSigner(null);
        setProvider(null);
      } else {
        connectWallet();
      }
    };

    const onChainChanged = () => {
      window.location.reload();
    };

    window.ethereum.on("accountsChanged", onAccountsChanged);
    window.ethereum.on("chainChanged", onChainChanged);

    return () => {
      window.ethereum.removeListener("accountsChanged", onAccountsChanged);
      window.ethereum.removeListener("chainChanged", onChainChanged);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (cooldown <= 0) return;
    const timer = setInterval(() => {
      setCooldown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(timer);
  }, [cooldown]);

  const canRequest =
    account &&
    chainOk &&
    cooldown === 0 &&
    status !== STATUS.WAITING_SIGNATURE &&
    status !== STATUS.PENDING;

  return (
    <div className="app">
      <header className="header">
        <div className="logo">
          <span className="logo-icon">⬡</span>
          <div>
            <h1>OPN Infrastructure Faucet</h1>
            <p className="subtitle">ERC20 token dispenser on OPN Testnet</p>
          </div>
        </div>
        {!account ? (
          <button className="btn btn-primary" onClick={connectWallet}>
            Connect MetaMask
          </button>
        ) : (
          <div className="wallet-info">
            <span className={`chain-badge ${chainOk ? "ok" : "warn"}`}>
              {chainOk ? "OPN Testnet" : "Wrong Network"}
            </span>
            <span className="address">
              {account.slice(0, 6)}…{account.slice(-4)}
            </span>
          </div>
        )}
      </header>

      <main className="main">
        {!chainOk && account && (
          <div className="alert alert-warn">
            <p>Please switch to OPN Testnet (Chain ID: {CHAIN_ID})</p>
            <button className="btn btn-secondary" onClick={switchNetwork}>
              Switch Network
            </button>
          </div>
        )}

        <div className="cards">
          <div className="card">
            <h2>Faucet Balance</h2>
            <p className="balance">
              {faucetBalance !== null
                ? `${formatTokens(faucetBalance)} ${tokenSymbol}`
                : "—"}
            </p>
          </div>

          <div className="card">
            <h2>Your Balance</h2>
            <p className="balance">
              {userBalance !== null
                ? `${formatTokens(userBalance)} ${tokenSymbol}`
                : "—"}
            </p>
          </div>

          <div className="card">
            <h2>Drip Amount</h2>
            <p className="balance">{formatTokens(dripAmount)} {tokenSymbol}</p>
          </div>

          <div className="card">
            <h2>Next Request</h2>
            <p className="balance countdown">
              {account
                ? cooldown > 0
                  ? formatCountdown(cooldown)
                  : "Available now"
                : "—"}
            </p>
          </div>
        </div>

        <div className="action-panel">
          <button
            className="btn btn-drip"
            onClick={requestTokens}
            disabled={!canRequest}
          >
            {status === STATUS.WAITING_SIGNATURE && "Confirm in MetaMask…"}
            {status === STATUS.PENDING && "Transaction pending…"}
            {(status === STATUS.IDLE ||
              status === STATUS.SUCCESS ||
              status === STATUS.ERROR) &&
              "Get Tokens"}
          </button>

          {status === STATUS.SUCCESS && (
            <div className="alert alert-success">
              <p>Successfully received {formatTokens(dripAmount)} {tokenSymbol}!</p>
              {txHash && (
                <a
                  href={`https://testnet.iopn.tech/tx/${txHash}`}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  View transaction →
                </a>
              )}
            </div>
          )}

          {status === STATUS.ERROR && errorMsg && (
            <div className="alert alert-error">
              <p>{errorMsg}</p>
            </div>
          )}
        </div>

        <footer className="footer">
          <p>
            Chain ID: {CHAIN_ID} ·{" "}
            <a
              href="https://testnet.iopn.tech"
              target="_blank"
              rel="noopener noreferrer"
            >
              Explorer
            </a>
          </p>
        </footer>
      </main>
    </div>
  );
}

export default App;
