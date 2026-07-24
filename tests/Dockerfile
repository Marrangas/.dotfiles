# Use a lightweight Debian image
FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    stow \
    python3 \
    python3-yaml \
    && rm -rf /var/lib/apt/lists/*

# Set up a test user to simulate home directory installations
RUN useradd -ms /bin/bash testuser
USER testuser
WORKDIR /home/testuser/dotfiles

# Copy the dotfiles repository
COPY --chown=testuser:testuser . .

# Run tests
CMD ["python3", "tests/run_tests.py"]
