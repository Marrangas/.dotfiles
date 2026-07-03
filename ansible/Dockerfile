FROM ubuntu:24.04

# Avoid interactive prompts during apt-get operations
ENV DEBIAN_FRONTEND=noninteractive

# Install core dependencies needed for the dotfiles and ansible deployment
RUN apt-get update && apt-get install -y \
    git \
    stow \
    python3 \
    python3-pip \
    ansible \
    sudo \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install 'just' tool reliably using the official installer script
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Create a non-root test user with passwordless sudo access
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the non-root test user and set workdir
USER testuser
WORKDIR /home/testuser

# Set up the expected dotfiles path
RUN mkdir -p /home/testuser/.dotfiles

# Copy current workspace into the test container
COPY --chown=testuser:testuser . /home/testuser/.dotfiles/

WORKDIR /home/testuser/.dotfiles

# By default, run the ansible playbook to deploy the standard profile inside the container
CMD ["ansible-playbook", "-i", "ansible/inventory.ini", "ansible/playbook.yml", "--connection=local"]
