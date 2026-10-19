
<!DOCTYPE html>
<html lang="en-ZA">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="theme-color" content="#07111f">

<title>Lee Forex AutoTrader</title>

<meta name="description" content="Lee Forex AutoTrader dashboard for monitoring forex strategies, risk settings and demo trading.">

<style>
:root {
  --bg: #07111f;
  --panel: #101e30;
  --panel2: #14263b;
  --border: #263c54;
  --text: #edf4ff;
  --muted: #9bb0c8;
  --blue: #36a3ff;
  --green: #27d69b;
  --red: #ff6277;
  --yellow: #ffc857;
  --purple: #b69cff;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: Arial, Helvetica, sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
}

header {
  background: #0b1929;
  border-bottom: 1px solid var(--border);
  padding: 20px;
}

.header-inner {
  max-width: 1200px;
  margin: auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 15px;
  flex-wrap: wrap;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: grid;
  place-items: center;
  background: linear-gradient(135deg, #168cff, #6248e8);
  font-weight: 900;
  font-size: 19px;
  color: white;
}

h1 {
  margin: 0;
  font-size: 23px;
}

.brand p {
  margin: 2px 0 0;
  color: var(--muted);
  font-size: 12px;
}

.status {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border: 1px solid #2b604e;
  border-radius: 30px;
  color: var(--green);
  background: #102a27;
  font-size: 12px;
  font-weight: bold;
}

.status-dot {
  height: 8px;
  width: 8px;
  border-radius: 50%;
  background: var(--green);
}

main {
  max-width: 1200px;
  margin: auto;
  padding: 22px;
}

.notice {
  border: 1px solid #6b5528;
  background: #2b2415;
  color: #ffe0a0;
  padding: 15px;
  border-radius: 12px;
  margin-bottom: 22px;
  font-size: 13px;
}

.hero {
  padding: 28px;
  background: linear-gradient(120deg, #132b47, #15203d);
  border: 1px solid var(--border);
  border-radius: 18px;
  margin-bottom: 22px;
}

.eyebrow {
  color: var(--blue);
  font-size: 12px;
  font-weight: bold;
  letter-spacing: 2px;
  text-transform: uppercase;
}

.hero h2 {
  font-size: clamp(25px, 5vw, 38px);
  margin: 8px 0;
  line-height: 1.2;
}

.hero p {
  color: #bfd0e5;
  max-width: 700px;
}

.button-row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 20px;
}

button,
.button {
  border: 0;
  border-radius: 9px;
  padding: 11px 16px;
  font-weight: bold;
  cursor: pointer;
  font-size: 13px;
  text-decoration: none;
}

.primary {
  background: var(--blue);
  color: #06111e;
}

.secondary {
  background: #22364d;
  color: white;
  border: 1px solid #3a526e;
}

.section-title {
  margin: 28px 0 13px;
  font-size: 18px;
}

.grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
}

.card {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 18px;
  min-width: 0;
}

.card-label {
  color: var(--muted);
  font-size: 12px;
}

.metric {
  font-size: 27px;
  font-weight: bold;
  margin: 8px 0 3px;
  overflow-wrap: anywhere;
}

.green {
  color: var(--green);
}

.red {
  color: var(--red);
}

.blue {
  color: var(--blue);
}

.yellow {
  color: var(--yellow);
}

.purple {
  color: var(--purple);
}

.small {
  color: var(--muted);
  font-size: 12px;
}

.two-columns {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: 16px;
  margin-top: 16px;
}

.table-wrap {
  width: 100%;
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  min-width: 480px;
  font-size: 13px;
}

th,
td {
  text-align: left;
  padding: 13px 10px;
  border-bottom: 1px solid var(--border);
}

th {
  color: var(--muted);
  font-size: 11px;
  text-transform: uppercase;
}

.pair {
  font-weight: bold;
}

.badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 6px;
  background: #1c344a;
  color: var(--blue);
  font-size: 11px;
  font-weight: bold;
}

.badge.green-badge {
  color: var(--green);
  background: #14352e;
}

.badge.yellow-badge {
  color: var(--yellow);
  background: #3a301b;
}

.settings {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
}

.field label {
  display: block;
  color: var(--muted);
  font-size: 12px;
  margin-bottom: 6px;
}

.field input,
.field select {
  width: 100%;
  padding: 12px;
  background: #091625;
  color: white;
  border: 1px solid #344a63;
  border-radius: 8px;
  font-size: 14px;
}

.field input:focus,
.field select:focus {
  outline: 2px solid var(--blue);
  border-color: var(--blue);
}

.info-box {
  background: var(--panel2);
  border-radius: 10px;
  padding: 14px;
  margin-top: 14px;
  font-size: 13px;
}

.progress {
  background: #26384c;
  height: 8px;
  border-radius: 20px;
  overflow: hidden;
  margin: 12px 0;
}

.progress-bar {
  height: 100%;
  width: 25%;
  background: var(--green);
  border-radius: 20px;
}

.check-list {
  padding-left: 20px;
  color: #c1d1e4;
  font-size: 13px;
}

.check-list li {
  margin: 9px 0;
}

footer {
  max-width: 1200px;
  margin: auto;
  padding: 25px 22px 35px;
  color: var(--muted);
  font-size: 12px;
  text-align: center;
  border-top: 1px solid var(--border);
}

footer strong {
  color: var(--blue);
}

@media (max-width: 850px) {
  .grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .two-columns {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  header {
    padding: 15px;
  }

  main {
    padding: 14px;
  }

  .hero {
    padding: 20px;
  }

  h1 {
    font-size: 19px;
  }

  .grid {
    gap: 9px;
  }

  .card {
    padding: 13px;
  }

  .metric {
    font-size: 22px;
  }

  .settings {
    grid-template-columns: 1fr;
  }

  .status {
    font-size: 11px;
  }
}
</style>
</head>

<body>

<header>
  <div class="header-inner">
    <div class="brand">
      <div class="logo">LEE</div>
      <div>
        <h1>Lee <span class="blue">Forex</span> <span class="green">AutoTrader</span></h1>
        <p>Forex Strategy & Risk Dashboard</p>
      </div>
    </div>

    <div class="status">
      <span class="status-dot"></span>
      DASHBOARD ONLINE
    </div>
  </div>
</header>

<main>

  <div class="notice">
    <strong>Important:</strong> This dashboard is not connected to your broker.
    The values shown are demonstration examples, not live account information.
    It does not place or manage trades. Never use these example figures to make
    financial decisions.
  </div>

  <section class="hero">
    <div class="eyebrow">LEE AUTOTRADER SYSTEM</div>

    <h2>Trade with a plan.<br>
      <span class="blue">Protect your capital.</span>
    </h2>

    <p>
      A clean dashboard for viewing your forex strategy, monitoring risk
      settings and preparing for demo testing before considering any live trading.
    </p>

    <div class="button-row">
      <button class="primary" onclick="showDemoNotice()">
        View Demo Status
      </button>

      <a class="button secondary"
         href="https://www.metatrader5.com/"
         target="_blank"
         rel="noopener noreferrer">
        MetaTrader 5 Website
      </a>
    </div>
  </section>

  <h2 class="section-title">Account Overview</h2>

  <section class="grid">
    <div class="card">
      <div class="card-label">Account Balance</div>
      <div class="metric blue">—</div>
      <div class="small">Waiting for broker connection</div>
    </div>

    <div class="card">
      <div class="card-label">Equity</div>
      <div class="metric purple">—</div>
      <div class="small">Live account data unavailable</div>
    </div>

    <div class="card">
      <div class="card-label">Open Positions</div>
      <div class="metric yellow">—</div>
      <div class="small">No trading feed connected</div>
    </div>

    <div class="card">
      <div class="card-label">Today's Profit/Loss</div>
      <div class="metric">—</div>
      <div class="small">No verified trading results</div>
    </div>
  </section>

  <div class="two-columns">

    <section class="card">
      <h2 class="section-title" style="margin-top:0">
        Currency Pairs
      </h2>

      <p class="small">
        Watchlist for the proposed strategy. These are not live prices or signals.
      </p>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Currency Pair</th>
              <th>Market</th>
              <th>Signal</th>
            </tr>
          </thead>

          <tbody>
            <tr>
              <td class="pair">EURUSD</td>
              <td>Forex</td>
              <td><span class="badge">No live data</span></td>
            </tr>

            <tr>
              <td class="pair">GBPUSD</td>
              <td>Forex</td>
              <td><span class="badge">No live data</span></td>
            </tr>

            <tr>
              <td class="pair">USDJPY</td>
              <td>Forex</td>
              <td><span class="badge">No live data</span></td>
            </tr>

            <tr>
              <td class="pair">USDCHF</td>
              <td>Forex</td>
              <td><span class="badge">No live data</span></td>
            </tr>

            <tr>
              <td class="pair">AUDUSD</td>
              <td>Forex</td>
              <td><span class="badge">No live data</span></td>
            </tr>

            <tr>
              <td class="pair">USDCAD</td>
              <td>Forex</td>
              <td><span class="badge">No live data</span></td>
            </tr>

            <tr>
              <td class="pair">NZDUSD</td>
              <td>Forex</td>
              <td><span class="badge">No live data</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section class="card">
      <h2 class="section-title" style="margin-top:0">
        Proposed Strategy
      </h2>

      <div class="info-box">
        <span class="blue">Strategy:</span>
        EMA 20 / EMA 50 trend confirmation
      </div>

      <div class="info-box">
        <span class="purple">Confirmation:</span>
        RSI indicator
      </div>

      <div class="info-box">
        <span class="yellow">Stop Loss:</span>
        ATR-based calculation
      </div>

      <div class="info-box">
        <span class="green">Take Profit:</span>
        Proposed reward-to-risk ratio of 1.5:1
      </div>

      <p class="small">
        These are proposed settings, not proof of profitability.
        Strategy performance must be tested.
      </p>
    </section>

  </div>

  <h2 class="section-title">Risk Management Settings</h2>

  <section class="card">
    <p class="small">
      Change these example values to explore the settings.
      They are saved only in this browser and do not control MetaTrader 5.
    </p>

    <div class="settings">

      <div class="field">
        <label for="risk">Proposed risk per trade (%)</label>
        <input id="risk" type="number" min="0.1" max="1"
               step="0.1" value="0.5">
      </div>

      <div class="field">
        <label for="dailyLoss">Example daily loss limit (%)</label>
        <input id="dailyLoss" type="number" min="0.5" max="5"
               step="0.5" value="2">
      </div>

      <div class="field">
        <label for="maxPositions">Maximum open positions</label>
        <select id="maxPositions">
          <option value="1">1 position</option>
          <option value="2">2 positions</option>
          <option value="3" selected>3 positions</option>
        </select>
      </div>

      <div class="field">
        <label for="timeframe">Proposed chart timeframe</label>
        <select id="timeframe">
          <option value="H1" selected>H1 — 1 hour</option>
          <option value="H4">H4 — 4 hours</option>
          <option value="D1">D1 — Daily</option>
        </select>
      </div>

    </div>

    <div class="button-row">
      <button class="primary" onclick="saveSettings()">
        Save Dashboard Settings
      </button>

      <button class="secondary" onclick="resetSettings()">
        Reset Settings
      </button>
    </div>

    <div class="info-box" id="settingsMessage" aria-live="polite">
      Dashboard settings have not been changed.
    </div>
  </section>

  <div class="two-columns">

    <section class="card">
      <h2 class="section-title" style="margin-top:0">
        System Checklist
      </h2>

      <ul class="check-list">
        <li><span class="green">●</span> Dashboard webpage loaded</li>
        <li><span class="yellow">●</span> Broker connection not configured</li>
        <li><span class="yellow">●</span> EA compilation not verified</li>
        <li><span class="yellow">●</span> Strategy backtest not verified</li>
        <li><span class="yellow">●</span> Demo forward testing not verified</li>
      </ul>
    </section>

    <section class="card">
      <h2 class="section-title" style="margin-top:0">
        Next Steps
      </h2>

      <ol class="check-list">
        <li>Save this website as <strong>index.html</strong>.</li>
        <li>Prepare the separate MQL5 Expert Advisor file.</li>
        <li>Compile and test the EA in MetaTrader 5 on a supported computer.</li>
        <li>Backtest and forward-test using a demo account.</li>
        <li>Check trade sizing, stop losses and drawdown before considering live trading.</li>
      </ol>
    </section>

  </div>

</main>

<footer>
  <strong>LEE FOREX AUTOTRADER</strong><br>
  Strategy dashboard · Demo preparation · Risk awareness<br><br>
  Forex trading involves significant risk. Losses can exceed expectations.
  No profit or trading outcome is guaranteed.
</footer>

<script>
const defaultSettings = {
  risk: "0.5",
  dailyLoss: "2",
  maxPositions: "3",
  timeframe: "H1"
};

function loadSettings() {
  try {
    const saved = localStorage.getItem("leeForexSettings");

    if (saved) {
      const settings = JSON.parse(saved);

      document.getElementById("risk").value =
        settings.risk ?? defaultSettings.risk;

      document.getElementById("dailyLoss").value =
        settings.dailyLoss ?? defaultSettings.dailyLoss;

      document.getElementById("maxPositions").value =
        settings.maxPositions ?? defaultSettings.maxPositions;

      document.getElementById("timeframe").value =
        settings.timeframe ?? defaultSettings.timeframe;
    }
  } catch (error) {
    console.log("Settings could not be loaded.");
  }
}

function saveSettings() {
  const risk = Number(document.getElementById("risk").value);
  const dailyLoss = Number(document.getElementById("dailyLoss").value);
  const maxPositions = Number(document.getElementById("maxPositions").value);
  const timeframe = document.getElementById("timeframe").value;

  if (!Number.isFinite(risk) || risk < 0.1 || risk > 1) {
    alert("Enter a risk value between 0.1% and 1%.");
    return;
  }

  if (!Number.isFinite(dailyLoss) || dailyLoss < 0.5 || dailyLoss > 5) {
    alert("Enter a daily loss limit between 0.5% and 5%.");
    return;
  }

  const settings = {
    risk: risk.toString(),
    dailyLoss: dailyLoss.toString(),
    maxPositions: maxPositions.toString(),
    timeframe: timeframe
  };

  try {
    localStorage.setItem("leeForexSettings", JSON.stringify(settings));

    document.getElementById("settingsMessage").textContent =
      "Settings saved in this browser only. They have not been sent to your broker or trading robot.";
  } catch (error) {
    document.getElementById("settingsMessage").textContent =
      "Your browser could not save these settings. You can still use the dashboard.";
  }
}

function resetSettings() {
  document.getElementById("risk").value = defaultSettings.risk;
  document.getElementById("dailyLoss").value = defaultSettings.dailyLoss;
  document.getElementById("maxPositions").value = defaultSettings.maxPositions;
  document.getElementById("timeframe").value = defaultSettings.timeframe;

  try {
    localStorage.removeItem("leeForexSettings");
  } catch (error) {
    // Reset the visible settings even if storage is unavailable.
  }

  document.getElementById("settingsMessage").textContent =
    "Dashboard settings have been reset. No broker settings were changed.";
}

function showDemoNotice() {
  alert(
    "Lee Forex AutoTrader dashboard is open. It is not connected to RCG Markets and cannot place trades. The separate Expert Advisor must be compiled and tested in MetaTrader 5."
  );
}

loadSettings();
</script>

</body>
</html>
