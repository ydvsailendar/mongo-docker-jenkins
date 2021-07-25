# FROM python:3.8-slim AS compile-image
# RUN apt-get update -y
# RUN apt-get upgrade -y
# RUN apt-get install -y --no-install-recommends build-essential gcc
# # RUN python3 -m venv /opt/venv
# # ENV PATH="/opt/venv/bin:$PATH"
# COPY .env .
# COPY server.py .
# COPY requirements.txt .
# RUN pip3 install -r requirements.txt
# CMD [ "python3 server.py" ]

# # FROM python:3.8-slim AS build-image
# # COPY --from=compile-image /opt/venv /opt/venv
# # ENV PATH="/opt/venv/bin:$PATH"

FROM python:3.8-slim-buster

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY server.py .
COPY .env .

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]