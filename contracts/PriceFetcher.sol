//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Namit Jain <namit.cs.rdjps@gmail.com> (https://www.linkedin.com/in/namit-jain-355367186/)
* 
* Implementation of PriceFetcher.
/******************************************************************************/

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface ITokenInfo {
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PriceFetcher is Ownable {

    address public pancakeFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    address public bnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 

    address public busdBnbAddress = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16; //Pancake-LP(BUSD-WBNB)

    address public busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 

    mapping(address => address[]) public pricePath;

    function setPricePath(address token,address[] memory path) external onlyOwner {
        pricePath[token] = path;
    }

    function fetchTokenPrice(address token) public view returns(uint256){

        try ITokenInfo(token).token0() returns(address) {

            address pairToken0 = ITokenInfo(token).token0();
            address pairToken1 = ITokenInfo(token).token1();
            uint256 decimal0 = 10**(ITokenInfo(pairToken0).decimals());
            uint256 decimal1 = 10**(ITokenInfo(pairToken1).decimals());
            (uint112 reserve0,uint112 reserve1,) = ITokenInfo(token).getReserves();
            uint token0Price;
            uint token1Price;
            {
                uint i = 0;
                while(i<2){

                    uint _price = 0;
                    address _token = i == 0 ? pairToken0 : pairToken1;
                    
                    if(pricePath[_token].length > 0){
                        _price = fetchTokenPriceInternal(_token, pricePath[_token]);
                    }
                    else{
                        
                        address tokenWithBusd = IFactory(pancakeFactory).getPair(busdAddress, _token);
                        address tokenWithBnb = IFactory(pancakeFactory).getPair(bnbAddress, _token);
    
                        if(tokenWithBnb != address(0)){
                            address[] memory path = new address[](2);
                            path[0] = tokenWithBnb;
                            path[1] = busdBnbAddress;
                            _price = fetchTokenPriceInternal(_token, path);
                        }
                        else if(tokenWithBusd != address(0)){
                            address[] memory path = new address[](1);
                            path[0] = tokenWithBusd;
                            _price = fetchTokenPriceInternal(_token, path);
                        }
                        else{
                            _price = 0;
                        }
                    }

                    if(i == 0){
                        token0Price = _price;
                    }
                    else{
                        token1Price = _price;
                    }
                    i++;
                }
                
            
            } 
            uint totalSupply = ITokenInfo(token).totalSupply();
            uint factor1 = (token0Price * reserve0 * decimal0) / 1e18;
            uint factor2 = (token1Price * reserve1 * decimal1) / 1e18;
            uint price = (factor1 + factor2) / totalSupply;
            return (price);

        }
        catch{

            if(pricePath[token].length > 0){
                return fetchTokenPriceInternal(token, pricePath[token]);
            }
            else{
    
                address tokenWithBusd = IFactory(pancakeFactory).getPair(busdAddress, token);
                address tokenWithBnb = IFactory(pancakeFactory).getPair(bnbAddress, token);
    
                if(tokenWithBnb != address(0)){
                    address[] memory path = new address[](2);
                    path[0] = tokenWithBnb;
                    path[1] = busdBnbAddress;
                    return fetchTokenPriceInternal(token, path);
                }
                else if(tokenWithBusd != address(0)){
                    address[] memory path = new address[](1);
                    path[0] = tokenWithBusd;
                    return fetchTokenPriceInternal(token, path);
                }
                else{
                    return 0;
                }
                
            }

        }

    }

    function fetchTokenPriceInternal(address token,address[] memory path) internal view returns(uint256) {

        uint[] memory prices = new uint[](path.length);
        for(uint i = 0 ; i < path.length ; i++){
            address pair = path[i];
            address pairToken0 = ITokenInfo(pair).token0();
            address pairToken1 = ITokenInfo(pair).token1();
            uint256 weiValue = 1e18;
            (uint112 reserve0,uint112 reserve1,) = ITokenInfo(pair).getReserves();
            
            if(token == pairToken0){
                uint decimal = ITokenInfo(token).decimals();
                uint extraDecimal;
                if(decimal < 18)
                extraDecimal = 10**(18-decimal); 
                else if(decimal > 18)
                extraDecimal = 10**(18+decimal); 
                else
                extraDecimal = 1;

                uint256 token1PerToken0 = ((reserve1 * weiValue)) / (reserve0) / extraDecimal;
                token = pairToken1;
                prices[i] = token1PerToken0;
            }
            else if(token == pairToken1){
                uint decimal = ITokenInfo(token).decimals();
                uint extraDecimal;
                if(decimal < 18)
                extraDecimal = 10**(18-decimal); 
                else if(decimal > 18)
                extraDecimal = 10**(18+decimal); 
                else
                extraDecimal = 1;
                uint256 token0PerToken1 = ((reserve0 * weiValue)) / (reserve1) / extraDecimal;
                token = pairToken0;
                prices[i] = token0PerToken1;
            }
            else{
                return 0;
            }
        }
        
        uint price = path.length > 0 ? 1e18 : 0;
        for(uint i = 0 ; i < prices.length ; i++){
            price = (price * prices[i]) / 1e18;
        }

        return price;
    }

    function fetchTokenSymbol(address token) external view returns(string memory symbol){

        try ITokenInfo(token).token0() returns(address) {
            //LP
            address token0 = ITokenInfo(token).token0();
            address token1 = ITokenInfo(token).token1();
            string memory symbol1 = ITokenInfo(token0).symbol();
            string memory symbol2 = ITokenInfo(token1).symbol();
            string memory symbol3 = ITokenInfo(token).symbol();
            return string(abi.encodePacked(symbol1,"-",symbol2,"(",symbol3,")"));
        }
        catch{
            //normal bep20
            return ITokenInfo(token).symbol();
        }

    }

}