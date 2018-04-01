pragma solidity ^0.4.17;
//the pragma line is the preprocessor directive, tells the version of solidity

contract Lottery {
	//struct is used to store the user information
	struct User {
		address userAddress;
		uint tokensBought;
    uint[] guess;
	}

	// a list of the users
	mapping (address => User) public users;

  address[] public userAddresses;

	address public owner;
	bytes32 public winningGuessSha3;

	//contructor function
	function Lottery(uint _winningGuess) {
		// by default the owner of the contract is accounts[0] to set the owner change truffle.js
		owner = msg.sender;
		winningGuessSha3 = keccak256(_winningGuess);
	}

  // returns the number of tokens purchased by an account
  function userTokens(address _user) view public returns (uint) {
    return users[_user].tokensBought;
  }

  // returns the guess made by user so far
  function userGuesses(address _user) view public returns(uint[]) {
    return users[_user].guess;
  }

  // to add a new user to the contract to make guesses
  function makeUser() public{
    users[msg.sender].userAddress = msg.sender;
    users[msg.sender].tokensBought = 0;
    userAddresses.push(msg.sender);
  }

	// function to add tokens to the user that calls the contract
  // the money sent using a payable modifier is held in the contract
  // money can be released using selfdestruct(address)
	function addTokens() payable {
    uint present = 0;
    uint tokensToAdd = msg.value/(10**18);

    for(uint i = 0; i < userAddresses.length; i++) {
      if(userAddresses[i] == msg.sender) {
        present = 1;
        break;
      }
    }

    // adding tokens if the user present in the userAddresses array
    if (present == 1) {
      users[msg.sender].tokensBought += tokensToAdd;
    }
	}

	// function to generate the random number that wins
	function makeGuess(uint _userGuess) {
    require(_userGuess < 1000000 && users[msg.sender].tokensBought > 0);
    users[msg.sender].guess.push(_userGuess);
    users[msg.sender].tokensBought--;
	}

	// doesn't allow anyone to buy anymore tokens
	function closeGame() {
    // can only be called my the owner of the contract
		require(owner == msg.sender);
    address winner = winnerAddress();
    getPrice(winner);
	}

	// returns the address of the winner once the game is closed
	function winnerAddress() returns(address){
    for(uint i = 0; i < userAddresses.length; i++) {
      User user= users[userAddresses[i]];

      for(uint j = 0; j < user.guess.length; j++) {
        if (keccak256(user.guess[j]) == winningGuessSha3) {
          return user.userAddress;
        }
      }
    }
    // the owner wins if there are no winning guesses
    return owner;
	}

	// sends 50% of the ETH in contract to the winner and rest of it to the owner
	function getPrice(winner) {
    // destroys the contact and sends all the money to the address mentioned
    selfdestruct(winner);
	}

}
