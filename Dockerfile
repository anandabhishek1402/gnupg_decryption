FROM debian:11-slim AS build
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    apt-get install -y gnupg && \
    /venv/bin/pip install --upgrade pip setuptools wheel

# Build the virtualenv as a separate step: Only re-execute this step when requirements.txt changes
FROM build AS build-venv
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt
WORKDIR /app

FROM gcr.io/distroless/python3-debian9:latest
COPY --from=build-venv /venv /venv
COPY main.py /app
COPY gunicorn_config.py /app
# WORKDIR /app
CMD ["gunicorn", "--config", "gunicorn_config.py", "main:app"]

