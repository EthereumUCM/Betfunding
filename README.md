# Betfunding
Betfunding is part of a bachelor's thesis done on June 2015 in the Faculty of Computer Sciences of the Complutense University of Madrid.  
[ES] Desarrollo de una plataforma de crowdfunding distribuida sobre Ethereum [(download)] (https://github.com/EthereumUCM/Betfunding/blob/master/pdf/MemoriaTFG.pdf)  
[EN] Development of a distributed crowdfunding platform on Ethereum


## Abstract
Betfunding is a decentralized crowdfunding platform that uses bets instead of
donations to support artistic production and creative work.  

Unlike other crowdfunding platforms, in Betfunding the investors are the ones
that suggest a project and look for creators by the creation of a bounty for their
work. Anyone can become a creator of a project if she pays a deposit as a
commitment to the users. The success or failure of a project will be determined
by a trusted third party designated at the beginning of the project that can be a
person or an automated system.  

The platform has been developed on Ethereum, a Bitcoin-like technology that
allows to manage money with cryptocurrencies and to develop decentralized
applications. The use of blockchain technology and cryptocurrencies avoid the
need for a trusted central authority to send and keep the money charging fees.
Instead of that, it is done through a peer-to-peer network in a transparent and
secure way.

## Authors
Adrián Calvo María  
Viktor Jacynycz García

## Directors
Samer Hassan Collado  
Antonio Sánchez Ruiz-Granados

## How to use it
1. Download AlethZero: https://github.com/ethereum/cpp-ethereum/wiki (Windows: http://build.ethdev.com/builds/Windows%20C%2B%2B%20master%20branch/AlethZero-Win32-latest.7z)
2. Copy this repository on your computer.
3. Copy the code inside Betfunding.sol and create a contract with it. Make sure that you have enough ether to pay for the transaction.
4. Copy the address of the contract and put it inside the file /frontend/scripts.js:  
 > var mainContractAddress = '0x' + 'PUT THAT ADDRESS HERE';
5. Finally, open /frontend/index.html using AlethZero.
