# build base image
FROM python:slim-bookworm as base

ENV PATH="/home/appuser/.local/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

ENV PIP_COMPILE_FLAGS="--generate-hashes --allow-unsafe --upgrade"
ENV PIP_INSTALL_FLAGS="--user --no-cache-dir --disable-pip-version-check --no-warn-script-location --upgrade"

# Install system dependencies
RUN apt-get update && apt-get install -qqy \
    build-essential \
    git \
    curl \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-venv \
    ffmpeg \
    gdal-bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Create a non-root user and group
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN echo 'appuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Set the home directory for the appuser
ENV HOME=/home/appuser
RUN mkdir -p $HOME && chown -R appuser:appuser $HOME

# Set work directory
WORKDIR /app

RUN pip install ${PIP_INSTALL_FLAGS}  psycopg2-binary \
    pip-tools