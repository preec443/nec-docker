# Dockerfile
FROM ubuntu:20.04

# Setting up environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    iptables \
    make \
    git \
    gcc \
    linux-headers-$(uname -r) \
    && rm -rf /var/lib/apt/lists/*

# Setting up networking (note: may not work as expected in Docker)
RUN sysctl -w net.ipv4.ip_forward=1 && \
    iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE && \
    systemctl stop ufw

# Install Golang
RUN wget https://golang.org/dl/go1.15.8.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.15.8.linux-amd64.tar.gz && \
    mkdir -p /root/go/{bin,pkg,src} && \
    echo 'export GOPATH=/root/go' >> /root/.bashrc && \
    echo 'export GOROOT=/usr/local/go' >> /root/.bashrc && \
    echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> /root/.bashrc && \
    echo 'export GO111MODULE=auto' >> /root/.bashrc && \
    source /root/.bashrc

# Verify Golang version
RUN /usr/local/go/bin/go version

# Install kernel module gtp5g
RUN git clone https://github.com/free5gc/gtp5g.git /root/gtp5g && \
    cd /root/gtp5g && \
    make && \
    make install

# Default command
CMD ["/bin/bash"]