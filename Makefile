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

# Deploy to Sepolia testnet
deploy-sepolia:
	@docker-compose exec tokenizer bash -c "source .env && forge script deployment/script/DeploySneak42Token.s.sol:DeploySneak42Token \
		--rpc-url \$$SEPOLIA_RPC_URL \
		--private-key \$$PRIVATE_KEY \
		--broadcast -vvvv"

# Verify contract on Etherscan
verify:
	@docker-compose exec tokenizer bash -c "source .env && forge verify-contract $(ADDRESS) code/src/Sneak42Token.sol:Sneak42Token \
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

# Rebuild from scratch
re: fclean build up

.PHONY: build up down logs exec clean fclean re