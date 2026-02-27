FROM node:20-slim

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/root/.foundry/bin:$PATH"
RUN foundryup

# Copy project files to the container
COPY . .

# Expose ports (needed to create local chain)
EXPOSE 8545

# Bash for the container use
CMD ["bash"]