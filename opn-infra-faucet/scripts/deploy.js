const fs = require("fs");
const path = require("path");
const hre = require("hardhat");

const FUND_AMOUNT = 500_000n * 10n ** 18n;
const EXPLORER = "https://testnet.iopn.tech/tx";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  if (!deployer) {
    throw new Error(
      "Немає DEPLOYER_PRIVATE_KEY у .env — див. .env.example"
    );
  }

  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Deployer:", deployer.address);
  console.log("OPN balance:", hre.ethers.formatEther(balance));

  if (balance === 0n) {
    throw new Error(
      "Баланс 0. Отримайте OPN: https://faucet.iopn.tech"
    );
  }

  console.log("\n[1/3] Deploy MyToken...");
  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const token = await MyToken.deploy(deployer.address);
  await token.waitForDeployment();
  const tokenTx = token.deploymentTransaction().hash;
  const tokenAddress = await token.getAddress();
  console.log("  MyToken:", tokenAddress);
  console.log("  TX:", `${EXPLORER}/${tokenTx}`);

  console.log("\n[2/3] Deploy Faucet...");
  const Faucet = await hre.ethers.getContractFactory("Faucet");
  const faucet = await Faucet.deploy(tokenAddress);
  await faucet.waitForDeployment();
  const faucetTx = faucet.deploymentTransaction().hash;
  const faucetAddress = await faucet.getAddress();
  console.log("  Faucet:", faucetAddress);
  console.log("  TX:", `${EXPLORER}/${faucetTx}`);

  console.log("\n[3/3] Fund faucet (500k OPIT)...");
  const fundTx = await token.transfer(faucetAddress, FUND_AMOUNT);
  await fundTx.wait();

  const faucetBal = await faucet.getFaucetBalance();
  console.log("  getFaucetBalance():", faucetBal.toString());

  const root = path.join(__dirname, "..");
  const replacements = [
    { file: "frontend/src/config.js", pairs: [["MYTOKEN_ADDRESS", tokenAddress], ["FAUCET_ADDRESS", faucetAddress]] },
    { file: "hackathon-application.md", pairs: [
      ["MYTOKEN_ADDRESS", tokenAddress],
      ["FAUCET_ADDRESS", faucetAddress],
      ["TX_MYTOKEN", tokenTx],
      ["TX_FAUCET", faucetTx],
    ]},
  ];

  for (const { file, pairs } of replacements) {
    const fp = path.join(root, file);
    let content = fs.readFileSync(fp, "utf8");
    for (const [from, to] of pairs) {
      content = content.split(from).join(to);
    }
    fs.writeFileSync(fp, content);
  }

  const readmePath = path.join(root, "README.md");
  let readme = fs.readFileSync(readmePath, "utf8");
  readme = readme.replace(/MYTOKEN_ADDRESS/g, tokenAddress);
  readme = readme.replace(/FAUCET_ADDRESS/g, faucetAddress);
  readme = readme.replace(/TX_MYTOKEN/g, tokenTx);
  readme = readme.replace(/TX_FAUCET/g, faucetTx);
  fs.writeFileSync(readmePath, readme);

  const out = {
    MyToken: tokenAddress,
    Faucet: faucetAddress,
    txMyToken: `${EXPLORER}/${tokenTx}`,
    txFaucet: `${EXPLORER}/${faucetTx}`,
    fundTx: `${EXPLORER}/${fundTx.hash}`,
  };
  fs.writeFileSync(
    path.join(root, "deployed.json"),
    JSON.stringify(out, null, 2)
  );

  console.log("\n✓ Деплой завершено. Оновлено config.js, README.md, hackathon-application.md");
  console.log("\n--- Надіслати в заявку ---");
  console.log(`MyToken:  ${tokenAddress}`);
  console.log(`Faucet:   ${faucetAddress}`);
  console.log(`TX deploy MyToken: ${EXPLORER}/${tokenTx}`);
  console.log(`TX deploy Faucet:  ${EXPLORER}/${faucetTx}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
