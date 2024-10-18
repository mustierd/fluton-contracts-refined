import { arbitrumSepolia, berachainTestnetbArtio, scrollSepolia, sepolia } from "viem/chains";

const addresses: {
  [key: number]: {
    deployer: `0x${string}`;
    sender: `0x${string}`;
    IBCHandler: `0x${string}`;
    cometblsClient: `0x${string}`;
    UCS01: `0x${string}`;
    UCS02: `0x${string}`;
    multicall: `0x${string}`;
  };
} = {
  [sepolia.id]: {
    deployer: "0x12cffF5aAd6Fc340BBE6F1fe674C5Aa78f0d1E0F",
    sender: "0x2c077908e1173ff1a6097ca9e2af547c1e5130c4",
    IBCHandler: "0xa390514f803a3b318b93bf6cd4beeb9f8299a0eb",
    cometblsClient: "0x96979ed96ae00d724109b5ad859568e1239c0837",
    UCS01: "0xd0081080ae8493cf7340458eaf4412030df5feeb",
    UCS02: "0x9153952f174a1bcd7a9b3818ff21ecf918d4dca9",
    multicall: "0x70BEDecc56C7104e410c1e4c25FcA0bcd29A0bA9",
  },
  [berachainTestnetbArtio.id]: {
    deployer: "0x17425b7d2d97E613dE2ADa01Dc472F76879E08Fe",
    sender: "0x27156Eb671984304ae75Da49aD60C4479B490A06",
    IBCHandler: "0x851c0EB711fe5C7c8fe6dD85d9A0254C8dd11aFD",
    cometblsClient: "0x702F0C9e4E0F5EB125866C6E2F57eC3751B4da1A",
    UCS01: "0x6F270608fB562133777AF0f71F6386ffc1737C30",
    UCS02: "0xD05751B3F4d8dCf8487DB33b57C523dD7DB11C25",
    multicall: "0x3147CA8f531070DDAC1b93700ef18E4Dd05b86ec",
  },
  [arbitrumSepolia.id]: {
    deployer: "0x7d00b15A53B8b14a482BF761653532F07b7DcBdE",
    sender: "0x50C9C35e0197e781e9aD7a3F6baDD8d01E45c377",
    IBCHandler: "0xb599bfcfb9D4fCaE9f8aB5D45d9A6F145E6b7573",
    cometblsClient: "0x2c84Dd2515e906a04C57c8604535CEAd6B2F5F73",
    UCS01: "0xBd346331b31f8C43CC378286Bfe49f2f7F128c39",
    UCS02: "0x4505EB10bc6E8DfB38C2AB65B3017fd0Ae223827",
    multicall: "0xd867c233ee0908FC7BC21095dA47F775F6479F2A",
  },
  [scrollSepolia.id]: {
    deployer: "0x8E6cbf264706486E533eA07399474d9e1616313d",
    sender: "0x6BFD43FE5cb241b360EC4a307700c6a42EE9F6cb",
    IBCHandler: "0x03792798d62F082a2748e686745a5Cd7Ab06Ee6D",
    cometblsClient: "0xf303226A9FF0a920a79BcC2d9012871735C0f611",
    UCS01: "0xA61Bdce84F44CA842D0EE9c1706A3C9fDD311DC2",
    UCS02: "0x8eEC1B331B46cDb1021718cf2422100eadD1e13e",
    multicall: "0x58FC3fB2d19A41bdbD5B5f4B12cf9C69172601C7",
  },
};

export default addresses;
