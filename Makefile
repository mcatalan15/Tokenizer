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

# ====================== BONUS PART ======================
deploy-bonus:
	@echo "🚀 Deploying BONUS (Token + Multisig 2/3)..."
	@docker-compose exec tokenizer bash -c ' \
		source .env && \
		forge script bonus/script/DeployWithMultisig.s.sol:DeployWithMultisig \
			--rpc-url "$$SEPOLIA_RPC_URL" \
			--private-key "$$PRIVATE_KEY" \
			--broadcast -vvvv'

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
        deploy-mandatory deploy-bonus verify verify-mandatory verify-bonus status