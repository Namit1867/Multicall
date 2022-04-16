const { expect} = require("chai");
const { ethers } = require("ethers");


describe("TEST MULTICALL",()=>{

    it("GET ALL TOKEN PRICES USING MULTICALL",async() => {

        multicall = await hre.ethers.getContractFactory("Multicall");
        multiCallInstance = await multicall.deploy();
        multiCallAddress = multiCallInstance.address;

        priceFetcher = await hre.ethers.getContractFactory("PriceFetcher");
        priceFetcherInstance = await priceFetcher.deploy();
        priceFetcherAddress = priceFetcherInstance.address;

        const abi = [
            "function fetchTokenPrice(address) view returns(uint256)",
            "function fetchTokenSymbol(address) view returns(string memory)",
        ];
        const iface = new ethers.utils.Interface(abi);

        const tokens = ["0x03028D2F8B275695A1c6AFB69A4765e3666e36d9",
                        "0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F",
                        "0xfb6115445Bff7b52FeB98650C87f44907E58f802",
                        "0xa1faa113cbE53436Df28FF0aEe54275c13B40975",
                        "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c",
                        "0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47",
                        "0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F",
                        "0xAD6cAEb32CD2c308980a548bD0Bc5AA4306c6c18",
                        "0xCa3F508B8e4Dd382eE878A314789373D80A5190A",
                        "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82",
                        "0x52CE071Bd9b1C4B00A0b92D298c512478CaD67e8",
                        "0xd4CB328A82bDf5f03eB737f37Fa6B370aef3e888",
                        "0xbA2aE424d960c26247Dd6c32edC70B295c744C43",
                        "0x2f657932E65905eA09c7aacfe898bf79e207c1C0",
                        "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d",
                        "0x55d398326f99059fF775485246999027B3197955",
                        "0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3",
                        "0x29cED01C447166958605519F10DcF8b0255fB379",];

        let target = [];
        let callData = [];
        for(let i = 0 ; i < tokens.length ; i++){
            const element = tokens[i];
            const data1 = iface.encodeFunctionData("fetchTokenPrice", [element]);
            const data2 = iface.encodeFunctionData("fetchTokenSymbol", [element]);
            target.push(priceFetcherAddress)
            callData.push(data1);
            target.push(priceFetcherAddress)
            callData.push(data2);
        }
        const output = (await multiCallInstance.aggregate(target,callData)).returnData;

        for(let i = 0 ; i < output.length ; i+=2){

            let price = (iface.decodeFunctionResult("fetchTokenPrice",output[i]))
            price = (price[0])
            let symbol = iface.decodeFunctionResult("fetchTokenSymbol",output[i+1])
            symbol = symbol[0]

            console.log(`${symbol} => `,`$${ethers.utils.formatEther(price)}`);
            console.log("-------------------------------------------------------------------------------")
            
        }

    })

})

// "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
// "0x03028D2F8B275695A1c6AFB69A4765e3666e36d9",
// "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c",
// "0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47",
// "0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F",
// "0xfb6115445Bff7b52FeB98650C87f44907E58f802",
// "0xa1faa113cbE53436Df28FF0aEe54275c13B40975",
// "0x0Eb3a705fc54725037CC9e008bDede697f62F335",
// "0xa184088a740c695E156F91f5cC086a06bb78b827",
// "0x1CE0c2827e2eF14D5C4f29a091d735A204794041",
// "0x715D400F88C167884bbCc41C5FeA407ed4D2f8A0",
// "0xAD6cAEb32CD2c308980a548bD0Bc5AA4306c6c18",
// "0xCa3F508B8e4Dd382eE878A314789373D80A5190A",
// "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82",
// "0x52CE071Bd9b1C4B00A0b92D298c512478CaD67e8",
// "0xd4CB328A82bDf5f03eB737f37Fa6B370aef3e888",
// "0xbA2aE424d960c26247Dd6c32edC70B295c744C43",
// "0x2f657932E65905eA09c7aacfe898bf79e207c1C0",
// "0x67ee3Cb086F8a16f34beE3ca72FAD36F7Db929e2",
// "0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402",
// "0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD",
// "0xCC42724C6683B7E57334c4E856f4c9965ED682bD",
// "0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE",
// "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56",
// "0x23396cF899Ca06c4472205fC903bDB4de249D6fC",
// "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d",
// "0x55d398326f99059fF775485246999027B3197955",
// "0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3",
// "0x29cED01C447166958605519F10DcF8b0255fB379",
// "0x2859e4544C4bB03966803b044A93563Bd2D0DD4D"