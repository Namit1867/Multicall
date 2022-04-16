# Multicall
An implementation of merging huge amount of web3 calls and get the data from smart contracts in a single call. 


# Price Fetcher

This is a simple contract which uses [staticcall] to fetch data from given target smart contracts.

The `contracts/Multicall.sol` contains the code to fetch the data from given target smart contracts.

## How to Get Started To use the Multicall:-

1. The most important thing is you prior have a clear understanding how static call works.

2. The second important thing is there is test file `test/test.js` which you can use to interact with Multicall.

3. In test file we have create multicalls for PriceFetcher contract [https://github.com/njrapidinnovation/PriceFetcher].

## Calling Multicall Functions:-

1.`delegateToViewImplementation(address implementation,bytes memory data)` use this function to get the enocoded return data of given function signature on given implementation address.

2.`aggregate(address[] memory target,bytes[] memory callData)` use this function to get the enocoded return data Array of given function signatures on given target addresses.

## Using test.js:-

1. Start a local node which forks the binance mainnet using this script. 
   `npx hardhat node --fork https://speedy-nodes-nyc.moralis.io/f19381e84e5c8dde5935ae3e/bsc/mainnet/archive`

2. Run the test using this script.
   `npx hardhat test`

## test.js output will be like this:-

AQUA-WBNB(Net-LP) =>  $956.746049895809669787
-------------------------------------------------------------------------------
ALPACA =>  $0.627987022618981448
-------------------------------------------------------------------------------
AAVE =>  $174.680935417568370811
-------------------------------------------------------------------------------
ALPHA =>  $0.376447699832139773
-------------------------------------------------------------------------------
BTCB =>  $40439.060365588617006183
-------------------------------------------------------------------------------
ADA =>  $0.960861208688502299
-------------------------------------------------------------------------------
ALPACA =>  $0.627987022618981448
-------------------------------------------------------------------------------
BAND =>  $3.752494718633788676
-------------------------------------------------------------------------------
BIFI =>  $1486.693254841323391327
-------------------------------------------------------------------------------
Cake =>  $8.080808634345876887
-------------------------------------------------------------------------------
COMP =>  $154.129694091633617181
-------------------------------------------------------------------------------
CREAM =>  $43.471729341642698755
-------------------------------------------------------------------------------
DOGE =>  $0.146192216915134014
-------------------------------------------------------------------------------
ROBODOGE =>  $0.000000000009078922
-------------------------------------------------------------------------------
USDC =>  $1.000831592038875374
-------------------------------------------------------------------------------
USDT =>  $0.999051483489499975
-------------------------------------------------------------------------------
DAI =>  $1.002371027876827935
-------------------------------------------------------------------------------
FRAX =>  $1.091648105722080605
-------------------------------------------------------------------------------

## Get Help and Join the Community

If you need help or would like to discuss Multicall then send me a message [on linkedin](https://www.linkedin.com/in/namit-jain-355367186/), or [email me](namit.cs.rdjps@gmail.com).

## Author

This Contract was written by Namit Jain.

Contact:

- https://www.linkedin.com/in/namit-jain-355367186/
- namit.cs.rdjps@gmail.com

## License

MIT license. See the license file.
Anyone can use or modify this software for their purposes.
