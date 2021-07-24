FROM python:3.8-slim AS compile-image
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends build-essential gcc
RUN python -m venv /opt/venv
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY server.py .
COPY .env .

FROM python:3.8-slim AS build-image
COPY --from=compile-image /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
CMD [ "server.py" ]