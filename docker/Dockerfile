# Git Workshop Docker Environment
# Provides a consistent Linux environment for all workshop participants

FROM ubuntu:22.04

LABEL maintainer="Git Workshop"
LABEL description="Consistent Git learning environment"

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials
RUN apt-get update && apt-get install -y \
    git \
    vim \
    nano \
    curl \
    wget \
    less \
    tree \
    bash-completion \
    gpg \
    openssh-client \
    man-db \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Configure Git with sane defaults
RUN git config --system init.defaultBranch main \
    && git config --system core.autocrlf input \
    && git config --system core.editor nano \
    && git config --system color.ui auto

# Create workshop user
RUN useradd -m -s /bin/bash workshop
USER workshop
WORKDIR /home/workshop

# Configure user-level Git
RUN git config --global user.name "Workshop User" \
    && git config --global user.email "workshop@example.com" \
    && git config --global init.defaultBranch main \
    && git config --global pull.rebase true \
    && git config --global core.editor nano

# Add useful aliases
RUN git config --global alias.st status \
    && git config --global alias.co checkout \
    && git config --global alias.br branch \
    && git config --global alias.ci commit \
    && git config --global alias.lg "log --oneline --graph --all" \
    && git config --global alias.last "log -1 HEAD" \
    && git config --global alias.unstage "restore --staged"

# Create exercises directory
RUN mkdir -p /home/workshop/exercises

# Add bash aliases
RUN echo 'alias ll="ls -la"' >> ~/.bashrc \
    && echo 'alias la="ls -A"' >> ~/.bashrc \
    && echo 'alias l="ls -CF"' >> ~/.bashrc \
    && echo 'export PS1="\[\033[01;32m\]workshop\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> ~/.bashrc

# Set working directory to exercises
WORKDIR /home/workshop/exercises

# Default command
CMD ["/bin/bash"]
