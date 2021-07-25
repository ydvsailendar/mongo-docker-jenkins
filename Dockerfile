# # ---- Base python ----
# FROM python:3.8-slim-buster AS base
# # Create app directory
# WORKDIR /app

# # ---- Dependencies ----
# FROM base AS dependencies
# COPY requirements.txt ./
# RUN pip3 install -r requirements.txt

# # ---- Copy Files/Build ----
# FROM base
# WORKDIR /app
# COPY server.py /app
# COPY .env /app
# COPY --from=dependencies /root/.cache /root/.cache
# COPY requirements.txt ./
# RUN pip install -r requirements.txt && rm -rf /root/.cache
# CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]

# ---- Python dependencies builder ----
FROM python:3.8-slim-buster AS builder

# Always set a working directory
WORKDIR /app

# Ensures that the python and pip executables used
# in the image will be those from our virtualenv.
ENV PATH="/venv/bin:$PATH"

# Install OS package dependencies.
RUN apt-get update && \
    apt-get install -y --no-install-recommends &&\
    rm -rf /var/lib/apt/lists/*

# Setup the virtualenv
RUN python3 -m venv /venv

# Install Python deps
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt


# ---- Python final app ----
FROM python:3.8-slim-buster AS app

# Extra python env
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PATH="/venv/bin:$PATH"


# Always set a working directory
WORKDIR /app

# Install OS package dependencies.
RUN apt-get update && \
    apt-get install -y --no-install-recommends &&\
    rm -rf /var/lib/apt/lists/*

# copy in Python environment
COPY --from=builder /venv /venv

# COPY app
COPY server.py ./
COPY .env ./

# Run the app
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]