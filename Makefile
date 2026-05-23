CONTAINER_NAME = tokenizer_dev
IMAGE_NAME = tokenizer

# ====================== CORE COMMANDS ======================
build:
	docker-compose build

up:
	@echo "🚀 Starting container..."
	@docker-compose up -d

shell:
	@echo "🔌 Connecting to container..."
	@docker-compose exec tokenizer bash

exec:
	docker-compose exec tokenizer $(CMD)

down:
	@echo "⏹️ Stopping containers..."
	@docker-compose down

clean:
	@echo "🧹 Cleaning..."
	@docker-compose down
	@docker container prune -f

fclean: clean
	@echo "🔥 Full cleanup..."	
	@docker-compose down --rmi all --volumes
	@docker system prune -f

re: fclean build up

logs:
	@docker-compose logs -f

# ====================== DEVELOPMENT ======================
install-deps:
	make exec CMD="forge install OpenZeppelin/openzeppelin-contracts"

build-contracts:
	make exec CMD="forge build"

test:
	make exec CMD="forge test -vvv"

# ====================== MANDATORY PART ======================
deploy-mandatory:
	@echo "🚀 Deploying MANDATORY (Kicks42Token)..."
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		forge script deployment/script/DeployKicks42Token.s.sol:DeployKicks42Token \
			--rpc-url "$$SEPOLIA_RPC_URL" \
			--private-key "$$PRIVATE_KEY" \
			--broadcast -vvvv'

# ====================== TRANSFER MANDATORY TOKENS ======================
transfer-mandatory:
	@echo "🚀 Preparing to transfer Kicks42Token..."
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		if [ -z "$$CONTRACT_ADDRESS" ]; then \
			echo "❌ CONTRACT_ADDRESS not found in .env!"; \
			echo "   Please run: make deploy-mandatory first"; \
			exit 1; \
		fi && \
		if [ -z "$$WALLET_RECEIVER" ]; then \
			echo "❌ WALLET_RECEIVER not found in .env!"; \
			echo "   Add this line to .env:"; \
			echo "   WALLET_RECEIVER=0xYourReceiverAddressHere"; \
			exit 1; \
		fi && \
		echo "📍 Using Token Contract: $$CONTRACT_ADDRESS" && \
		echo "📤 Sending 500 K42T to: $$WALLET_RECEIVER" && \
		cast send $$CONTRACT_ADDRESS \
			"transfer(address,uint256)" \
			$$WALLET_RECEIVER \
			500000000000000000000 \
			--private-key "$$PRIVATE_KEY" \
			--rpc-url "$$SEPOLIA_RPC_URL" && \
		echo "✅ Transfer successful!" && \
		echo "🔗 Etherscan: https://sepolia.etherscan.io/token/$$CONTRACT_ADDRESS"'

# ====================== BONUS PART ======================
deploy-bonus:
	@echo "🚀 Deploying BONUS (Token + Multisig 2/3)..."
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		forge script bonus/script/DeployWithMultisig.s.sol:DeployWithMultisig \
			--rpc-url "$$SEPOLIA_RPC_URL" \
			--private-key "$$PRIVATE_KEY" \
			--broadcast -vvvv'

test-bonus:
	@echo "🧪 Running BONUS Fork Tests (Multisig + Token)..."
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		forge test bonus/tests/MultisigBonus.t.sol -vvv'

# ====================== TRANSFER VIA MULTISIG (BONUS) ======================
# ====================== MULTISIG TRANSFER - STEP 1 (SUBMIT) ======================
# Run this first (Owner 1 submits the transfer)
submit-bonus:
	@echo "🚀 Submitting transfer via Multisig (Owner 1)..."
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		echo "Token     : $$TOKEN_ADDRESS" && \
		echo "Multisig  : $$MULTISIG_ADDRESS" && \
		echo "Receiver  : $$WALLET_RECEIVER" && \
		echo "" && \
		echo "Submitting 500 K42T..." && \
		cast send $$MULTISIG_ADDRESS \
			"submitTransaction(address,uint256,bytes)" \
			$$TOKEN_ADDRESS 0 \
			$$(cast calldata "transfer(address,uint256)" $$WALLET_RECEIVER 500000000000000000000) \
			--private-key "$$PRIVATE_KEY" \
			--rpc-url "$$SEPOLIA_RPC_URL"'

# ====================== TRANSFER TOKENS TO MULTISIG ======================
# Transfer tokens from deployer to Multisig so it has funds to distribute
fund-multisig:
	@echo "💰 Funding Multisig with tokens..."
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		echo "From       : $$WALLET_ADDRESS" && \
		echo "To         : $$MULTISIG_ADDRESS" && \
		echo "Token      : $$TOKEN_ADDRESS" && \
		echo "Amount     : 1000 K42T" && \
		echo "" && \
		FUND_TX=$$(cast send $$TOKEN_ADDRESS \
			"transfer(address,uint256)" \
			$$MULTISIG_ADDRESS \
			1000000000000000000000 \
			--private-key "$$PRIVATE_KEY" \
			--rpc-url "$$SEPOLIA_RPC_URL" 2>&1 | grep "transactionHash" | awk "{print \$$2}") && \
		echo "✅ Tokens sent to Multisig!" && \
		echo "🔗 TX: https://sepolia.etherscan.io/tx/$$FUND_TX"'

# ====================== MULTISIG TRANSFER - ONE-STEP EXECUTION ======================
# Submits AND confirms transfer automatically using both private keys (2/2 multisig)
transfer-bonus:
	@echo "🚀 Executing 500 K42T transfer via Multisig (2/2)..."
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		echo "Token     : $$TOKEN_ADDRESS" && \
		echo "Multisig  : $$MULTISIG_ADDRESS" && \
		echo "Receiver  : $$WALLET_RECEIVER" && \
		echo "" && \
		echo "Checking Multisig deployment..." && \
		CODE=$$(cast code $$MULTISIG_ADDRESS --rpc-url "$$SEPOLIA_RPC_URL") && \
		if [ "$$CODE" = "0x" ]; then \
			echo "❌ Multisig contract not deployed!"; \
			echo "   Run: make deploy-bonus"; \
			exit 1; \
		fi && \
		echo "✅ Multisig contract found" && \
		echo "" && \
		echo "Getting current TX count..." && \
		TX_ID=$$(cast call $$MULTISIG_ADDRESS "transactionCount()(uint256)" --rpc-url "$$SEPOLIA_RPC_URL" | xargs printf "%d") && \
		echo "📍 New transaction ID will be: $$TX_ID" && \
		echo "" && \
		echo "Step 1️⃣  Submitting transfer (Owner 1 - Deployer)..." && \
		SUBMIT_TX=$$(cast send $$MULTISIG_ADDRESS \
			"submitTransaction(address,uint256,bytes)" \
			$$TOKEN_ADDRESS 0 \
			$$(cast calldata "transfer(address,uint256)" $$WALLET_RECEIVER 500000000000000000000) \
			--private-key "$$PRIVATE_KEY" \
			--rpc-url "$$SEPOLIA_RPC_URL" 2>&1 | grep "transactionHash" | awk "{print \$$2}") && \
		echo "📝 Submit TX: $$SUBMIT_TX" && \
		echo "" && \
		echo "Step 2️⃣  Confirming transfer (Owner 2 - WALLET_RECEIVER) with TX ID $$TX_ID..." && \
		CONFIRM_TX=$$(cast send $$MULTISIG_ADDRESS \
			"confirmTransaction(uint256)" \
			$$TX_ID \
			--private-key "$$SECOND_PRIVATE_KEY" \
			--rpc-url "$$SEPOLIA_RPC_URL" 2>&1 | grep "transactionHash" | awk "{print \$$2}") && \
		echo "📝 Confirm TX: $$CONFIRM_TX" && \
		echo "" && \
		echo "✅ Transfer executed! 500 K42T sent to $$WALLET_RECEIVER" && \
		echo "" && \
		echo "🔗 Etherscan Links:" && \
		echo "   Submit: https://sepolia.etherscan.io/tx/$$SUBMIT_TX" && \
		echo "   Confirm: https://sepolia.etherscan.io/tx/$$CONFIRM_TX" && \
		echo "   Token: https://sepolia.etherscan.io/token/$$TOKEN_ADDRESS"'

# ====================== MULTISIG TRANSFER - STEP 2 (CONFIRM) ======================
# Run this second (Owner 2 confirms)
# Usage: make confirm-bonus TX_ID=0x...
confirm-bonus:
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		if [ -z "$(TX_ID)" ]; then \
			echo "❌ Usage: make confirm-bonus TX_ID=0x..."; \
			exit 1; \
		fi && \
		echo "2️⃣ Confirming transaction with TX_ID = $(TX_ID)" && \
		cast send $$MULTISIG_ADDRESS \
			"confirmTransaction(uint256)" \
			$(TX_ID) \
			--private-key "$$SECOND_PRIVATE_KEY" \
			--rpc-url "$$SEPOLIA_RPC_URL" && \
		echo "✅ Confirmation sent! The transfer should now execute."'

# ====================== VERIFICATION ======================
verify:
	@docker-compose exec tokenizer bash -c "source .env && forge verify-contract $(ADDRESS) $(PATH):$(NAME) \
		--chain sepolia --etherscan-api-key '\$$ETHERSCAN_API_KEY' --watch"

verify-mandatory:
	@echo "🔍 Verifying mandatory contract..."
	@make verify ADDRESS=$(shell grep CONTRACT_ADDRESS .env | cut -d= -f2) PATH=code/src/Kicks42Token.sol NAME=Kicks42Token

verify-bonus:
	@echo "🔍 Verifying bonus contracts (token + multisig)..."
	@make verify ADDRESS=$(shell grep TOKEN_ADDRESS .env | cut -d= -f2) PATH=code/src/Kicks42Token.sol NAME=Kicks42Token || true
	@make verify ADDRESS=$(shell grep MULTISIG_ADDRESS .env | cut -d= -f2) PATH=bonus/src/Multisig.sol NAME=Multisig || true

# ====================== STATUS ======================
status:
	@echo "📋 Current Contract Status:"
	@grep -E "CONTRACT_ADDRESS|TOKEN_ADDRESS|MULTISIG_ADDRESS" .env || echo "No addresses saved yet"

.PHONY: build up down shell exec clean fclean re logs install-deps build-contracts test \
        deploy-mandatory deploy-bonus verify verify-mandatory verify-bonus status \
        test-bonus transfer-mandatory submit-bonus transfer-bonus confirm-bonus fund-multisig