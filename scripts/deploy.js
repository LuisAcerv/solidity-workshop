async function main() {
  // We get the contract to deploy
  const Escrow = await ethers.getContractFactory("Escrow");
  const escrow = await Escrow.deploy(
    "1000000000000000000", // 1 ether
    "1000000000000000", // 0.001 ether
    "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199", // Seller
    "0xdD2FD4581271e230360230F9337D5c0430Bf44C0" // Buyer
  );

  console.log("Escrow deployed to:", escrow.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
