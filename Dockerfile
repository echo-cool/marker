# Use an Ubuntu base image
FROM ubuntu:latest

# Set the working directory
WORKDIR /app

# Install system requirements
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:alex-p/tesseract-ocr-devel && \
    apt-get update && \
    apt-get install -y tesseract-ocr git curl ghostscript python3 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Clone the Marker repository
RUN git clone https://github.com/VikParuchuri/marker.git

# Set the working directory to the Marker directory
WORKDIR /app/marker

# Install Python requirements using Poetry
# Note: Adjust the PyTorch installation commands based on your target (CPU or GPU)
RUN /root/.local/bin/poetry install && \
    /root/.local/bin/poetry run pip install torch

# Add tessdata prefix environment variable
# Adjust the tessdata path as necessary. This is an example path.
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata

# Expose volume for input and output
VOLUME ["/data"]

# Set the entrypoint to use Poetry's shell, enabling `marker` command availability
ENTRYPOINT ["/root/.local/bin/poetry", "run"]

# Default command can be to display help or to OCR PDFs in /data directory
CMD ["marker", "--help"]
