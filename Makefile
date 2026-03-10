CONTAINER_NAME = tokenizer_dev
IMAGE_NAME = tokenizer

# Build Docker image
build:
	docker-compose build

# Start the container in detached mode
up:
	@echo "🚀 Starting container..."
	@docker-compose up -d

# Connect to the running container
shell:
	@echo "🔌 Connecting to container..."
	@docker-compose exec tokenizer bash

# Run a command inside the running container
exec:
	docker-compose exec tokenizer $(CMD)

# Install dependencies (OpenZeppelin)
install-deps:
	make exec CMD="forge install OpenZeppelin/openzeppelin-contracts"

# Build Contracts
build-contracts:
	make exec CMD="forge build"

# Run Tests
test:
	make exec CMD="forge test -vvv"

# Deploy to Sepolia testnet and update .env with contract address
deploy-sepolia:
	@echo "🚀 Deploying to Sepolia..."
	@docker-compose exec tokenizer bash -c "source .env && forge script deployment/script/DeployKicks42Token.s.sol:DeployKicks42Token \
		--rpc-url \$$SEPOLIA_RPC_URL \
		--private-key \$$PRIVATE_KEY \
		--broadcast -vvvv"
	@echo "📝 Updating .env with deployed contract address..."
	@NEW_ADDRESS=$$(cat broadcast/DeployKicks42Token.s.sol/11155111/run-latest.json | grep -o '"contractAddress": "[^"]*"' | head -1 | cut -d'"' -f4); \
	if [ ! -z "$$NEW_ADDRESS" ]; then \
		if grep -q "^CONTRACT_ADDRESS=" .env; then \
			sed -i '' "s/^CONTRACT_ADDRESS=.*/CONTRACT_ADDRESS=$$NEW_ADDRESS/" .env; \
			echo "✅ Updated CONTRACT_ADDRESS in .env: $$NEW_ADDRESS"; \
		else \
			echo "CONTRACT_ADDRESS=$$NEW_ADDRESS" >> .env; \
			echo "✅ Added CONTRACT_ADDRESS to .env: $$NEW_ADDRESS"; \
		fi; \
		echo "🔗 Etherscan: https://sepolia.etherscan.io/address/$$NEW_ADDRESS"; \
	else \
		echo "❌ Could not extract contract address from deployment"; \
	fi

# Get the last deployed contract address
get-address:
	@echo "🔍 Last deployed contract address:"
	@cat broadcast/DeployKicks42Token.s.sol/11155111/run-latest.json | grep -o '"contractAddress": "[^"]*"' | head -1 | cut -d'"' -f4

# Show contract status from .env
status:
	@echo "📋 Contract Status:"
	@if grep -q "^CONTRACT_ADDRESS=" .env; then \
		ADDRESS=$$(grep "^CONTRACT_ADDRESS=" .env | cut -d'=' -f2); \
		echo "📍 Contract Address: $$ADDRESS"; \
		echo "🔗 Etherscan: https://sepolia.etherscan.io/address/$$ADDRESS"; \
		echo "🔗 Etherscan Token: https://sepolia.etherscan.io/token/$$ADDRESS"; \
	else \
		echo "❌ No CONTRACT_ADDRESS found in .env"; \
		echo "💡 Deploy first with: make deploy-sepolia"; \
	fi

# Verify contract on Etherscan (use: make verify ADDRESS=0x...)
verify:
	@if [ -z $(ADDRESS) ]; then \
		echo "❌ Error: Please provide contract ADDRESS"; \
		echo "Usage: make verify ADDRESS=0x435767284620b56ae037d8a9c4a9cccb882bd7aa"; \
		echo "Or get the address with: make get-address"; \
		exit 1; \
	fi
	@echo "🔍 Verifying contract at address: $(ADDRESS)"
	@docker-compose exec tokenizer bash -c "source .env && forge verify-contract $(ADDRESS) code/src/Kicks42Token.sol:Kicks42Token \
		--chain sepolia --etherscan-api-key \$$ETHERSCAN_API_KEY --watch"

# Verify the last deployed contract automatically
verify-last:
	@echo "🔍 Verifying contract from .env..."
	@docker-compose exec tokenizer bash -c "source .env && \
		if [ -z \"\$$CONTRACT_ADDRESS\" ]; then \
			echo '❌ CONTRACT_ADDRESS not found in .env. Deploy first with: make deploy-sepolia'; \
			exit 1; \
		fi && \
		echo '🔍 Verifying contract at address:' \$$CONTRACT_ADDRESS && \
		forge verify-contract \$$CONTRACT_ADDRESS code/src/Kicks42Token.sol:Kicks42Token \
		--chain sepolia --etherscan-api-key \$$ETHERSCAN_API_KEY --watch"
# Stop and remove containers
down:
	@echo "⏹️ Stopping containers..."
	@docker-compose down

# Clean: stop and remove containers
clean:
	@echo "🧹 Stopping and removing containers..."
	@docker-compose down
	@docker container prune -f
	@echo "✅ Containers cleaned"

# Force clean: remove containers, images, and volumes
fclean: clean
	@echo "🔥 Removing images and volumes..."
	@docker-compose down --rmi all --volumes
	@docker system prune -f
	@echo "✅ Full cleanup completed"

# Rebuild from scratch
re: fclean build up

# Show logs
logs:
	@docker-compose logs -f

.PHONY: build up down shell exec clean fclean re logs
	@echo "🔥 Removing images and volumes..."
	@docker image rm $(IMAGE_NAME) 2>/dev/null || true
	@docker image prune -f
	@docker volume prune -f
	@docker system prune -f
	@echo "✅ Full cleanup completed"