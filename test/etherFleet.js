var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers, upgrades } = require("hardhat");
var { time } = require("@nomicfoundation/hardhat-network-helpers");

const pETH = ethers.parseEther
const fETH = ethers.formatEther
const pUNI = ethers.parseUnits
const fUNI = ethers.formatUnits
const log = console.log
const oneMonth = 2629743
const unlockDuration = Math.floor(Date.now() / 1000) + oneMonth

describe("EtherFleet", () => {
    async function loadTest() {
        var [owner, alice, bob, carl] = await ethers.getSigners()

        var usdt = await ethers.deployContract("TetherUSD")
        var busd = await ethers.deployContract("BinanceUSD")
        var ethfl = await ethers.deployContract("EtherFleet")
        var chest = await ethers.deployContract("Chest", [unlockDuration])

        var PIRATES = await ethers.getContractFactory("EtherFleetPirates")
        var pirates = await upgrades.deployProxy(
            PIRATES,
            [ethfl.target, pETH("15"), 50, [usdt.target, busd.target], chest.target],
            { initializer: 'initialize', kind: 'uups' }
        )

        var SHIPS = await ethers.getContractFactory("EtherFleetShips")
        var ships = await upgrades.deployProxy(
            SHIPS,
            [ethfl.target, pETH("30"), 50, [usdt.target, busd.target], chest.target],
            { initializer: 'initialize', kind: 'uups' }
        )

        await ethfl.transfer(pirates, pETH("1000"))
        await ethfl.transfer(ships, pETH("1000"))

        return { pirates, ships, chest, ethfl, usdt, busd, owner, alice, bob, carl }
    }

    describe("Mint", async () => {
        it("Mint", async () => {
            var { pirates, ships, chest, ethfl, usdt, busd, owner, alice, bob, carl } = await loadTest()
        })
    })
})