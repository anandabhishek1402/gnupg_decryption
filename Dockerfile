# FROM debian:11-slim AS build
# RUN apt-get update && \
#     apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev && \
#     python3 -m venv /venv && \
#     apt-get install -y gnupg && \
#     /venv/bin/pip install --upgrade pip setuptools wheel

# # Build the virtualenv as a separate step: Only re-execute this step when requirements.txt changes
# FROM build AS build-venv
# COPY requirements.txt /requirements.txt
# RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt
# WORKDIR /app

# FROM gcr.io/distroless/python3-debian9:latest
# COPY --from=build-venv /venv /venv
# COPY main.py /app
# COPY gunicorn_config.py /app
# # WORKDIR /app
# CMD ["gunicorn", "--config", "gunicorn_config.py", "main:app"]

# FROM python:3.7-slim AS build
# ADD . /app
# WORKDIR /app

# RUN apt-get update && \
#     apt-get install -y gnupg

# RUN chmod u+x /app/main.py
# RUN chmod u+x /app/gunicorn_config.py
# RUN chmod u+x /app/requirements.txt
# RUN pip3 install --ignore-installed -r requirements.txt

# FROM gcr.io/distroless/python3-debian10
# COPY --from=build /app /app
# COPY --from=build /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages

# WORKDIR /app
# ENV PYTHONPATH=/usr/local/lib/python3.7/site-packages
# CMD exec gunicorn --config gunicorn_config.py main:app
# # CMD ["gunicorn", "--config", "gunicorn_config.py", "main:app"]


FROM python:3.7-slim AS build
ADD . /home/app
WORKDIR /home/app

RUN apt-get update && \
    apt-get install -y gnupg

RUN groupadd -g 999 app && useradd -r -u 999 -g app app
RUN mkdir /home/app/.gnupg && chmod 700 /home/app/.gnupg
RUN chown -R app:app /home/app
# USER app
RUN chmod u+x /home/app/main.py
RUN chmod u+x /home/app/gunicorn_config.py
RUN chmod u+x /home/app/requirements.txt
RUN pip install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt


FROM gcr.io/distroless/python3-debian10
# USER app
COPY --from=build /home/app /home/app
COPY --from=build /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages
COPY --from=build /usr/lib/gnupg /usr/lib/gnupg
# COPY --from=build /usr/share/gnupg /usr/share/gnupg
COPY --from=build /usr/bin/gpg /usr/bin/gpg
COPY --from=build /usr/bin /usr/bin
COPY --from=build /usr/lib/gnupg /usr/lib/gnupg
COPY --from=build /usr/lib/gnupg2 /usr/lib/gnupg2

WORKDIR /home/app
ENV PYTHONPATH=/usr/local/lib/python3.7/site-packages
# CMD exec gunicorn --config gunicorn_config.py main:app
CMD ["main.py"]

