FROM python:3.12.6-slim

# Create a non-root user `runwhen` to run commands
ENV RUNWHEN_HOME=/home/runwhen
ENV REPO=helm-charts
RUN groupadd -r runwhen && \
    useradd -r -g runwhen -d $RUNWHEN_HOME -m -s /bin/bash runwhen && \
    mkdir -p $RUNWHEN_HOME && \
    chown -R runwhen:runwhen $RUNWHEN_HOME 

RUN mkdir $RUNWHEN_HOME/$REPO
WORKDIR $RUNWHEN_HOME/$REPO

# Install CLI tools and OS app dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    entr curl wget jq bc vim dnsutils unzip git apt-transport-https lsb-release bsdmainutils \
    build-essential file locales procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc /usr/share/man /usr/share/info /var/cache/man


# Install sudo
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN   echo "runwhen ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install AWS CLI v2 using tarball
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws


# Install yq
RUN curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq

# Adjust permissions for runwhen user
RUN chown runwhen:0 -R $RUNWHEN_HOME/

# Switch to the runwhen user for Homebrew installation
USER runwhen

RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew \
&& mkdir ~/.linuxbrew/bin \
&& ln -s ../Homebrew/bin/brew ~/.linuxbrew/bin \
&& eval $(~/.linuxbrew/bin/brew shellenv) \
&& brew --version

# Switch back to root to finalize environment
USER root

# Set RunWhen Temp Dir
RUN mkdir -p /var/tmp/runwhen && chmod 1777 /var/tmp/runwhen
ENV TMPDIR=/var/tmp/runwhen

# Copy files into container with correct ownership
COPY --chown=runwhen:0 . .

# Adjust permissions for runwhen user
RUN chown runwhen:0 -R $RUNWHEN_HOME/$REPO

# Set up Homebrew path for the runwhen user in the Docker build process
ENV PATH="/home/runwhen/.linuxbrew/bin:$PATH"


# Switch back to the 'runwhen' user as default
USER runwhen

RUN brew install \
    go-task \
    helm

CMD ["bash"]