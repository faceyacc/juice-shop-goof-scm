# Start with a base image with known vulnerabilities
FROM ubuntu:16.04

# Set environment variables (could expose sensitive information)
ENV APP_SECRET=mysecretpassword

# Install packages with known vulnerabilities
RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create a user with weak password and give it root privileges
RUN useradd -ms /bin/bash vulnerableuser && echo "vulnerableuser:password123" | chpasswd && adduser vulnerableuser sudo

# Expose a default port without specifying the protocol
EXPOSE 8080

# Copy application files to the container
COPY . /app

# Set a working directory
WORKDIR /app

# Install application dependencies (using pip without any versioning)
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install --no-cache-dir -r requirements.txt

# Run the application with root privileges
CMD ["python3", "app.py"]
