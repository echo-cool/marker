# Use an Ubuntu base image
FROM ubuntu:latest

# Set the working directory
WORKDIR /app

# Install system requirements including libmagic
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:alex-p/tesseract-ocr-devel && \
    apt-get update && \
    apt-get install -y tesseract-ocr git curl ghostscript python3 python3-pip python3-venv libmagic1 libmagic-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Clone the Marker repository
RUN git clone https://github.com/VikParuchuri/marker.git

# Set the working directory to the Marker directory
WORKDIR /app/marker

# Install Python requirements using Poetry
RUN /root/.local/bin/poetry install
RUN poetry remove torch
# Install PyTorch for CPU only
# Note: Adjust the command below to install the correct version of PyTorch for your needs.
# You might want to check https://pytorch.org for the latest command to install PyTorch for CPU.
RUN /root/.local/bin/poetry run pip install torch==1.10.0+cpu torchvision==0.11.1+cpu torchaudio==0.10.0+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html

# Add tessdata prefix environment variable
# Adjust the tessdata path as necessary. This is an example path.
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata

# Expose volume for input and output
VOLUME ["/data"]

# Set the entrypoint to use Poetry's shell, enabling `marker` command availability
ENTRYPOINT ["/root/.local/bin/poetry", "run"]

# Default command can be to display help or to OCR PDFs in /data directory
CMD ["marker", "--help"]
