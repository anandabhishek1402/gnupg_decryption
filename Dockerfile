FROM python:3.11-bookworm AS build
RUN mkdir /home/app
COPY main.py /home/app
COPY requirements.txt /home/app
COPY gunicorn_config.py /home/app
WORKDIR /home/app
RUN apt-get update && \
    apt-get install -y gnupg
RUN pip install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt --target=/home/app/packages

#Distroless Image
FROM gcr.io/distroless/python3-debian12
COPY --from=build /home/app/ /home/app/
ENV PYTHONPATH=/home/app/packages:$PYTHONPATH
COPY --from=build /usr/bin/gpg /usr/bin/gpg
COPY --from=build /lib/x86_64-linux-gnu/libgcrypt.so.20 /lib/x86_64-linux-gnu/libgcrypt.so.20
COPY --from=build /lib/x86_64-linux-gnu/libgcrypt.so.20.4.1 /lib/x86_64-linux-gnu/libgcrypt.so.20.4.1
COPY --from=build /lib/x86_64-linux-gnu/libassuan.so.0 /lib/x86_64-linux-gnu/libassuan.so.0 
COPY --from=build /lib/x86_64-linux-gnu/libassuan.so.0.8.5 /lib/x86_64-linux-gnu/libassuan.so.0.8.5
COPY --from=build /lib/x86_64-linux-gnu/libreadline.so.8 /lib/x86_64-linux-gnu/libreadline.so.8
COPY --from=build /lib/x86_64-linux-gnu/libreadline.so.8.2 /lib/x86_64-linux-gnu/libreadline.so.8.2
COPY --from=build /lib/x86_64-linux-gnu/libgpg-error.so.0.33.1 /lib/x86_64-linux-gnu/libgpg-error.so.0.33.1
COPY --from=build /lib/x86_64-linux-gnu/libgpg-error.so.0 /lib/x86_64-linux-gnu/libgpg-error.so.0
COPY --from=build /usr/lib/python3.11/http/ /usr/lib/python3.11/http/
ENV PYTHONPATH=/usr/local/lib/python3.11:$PYTHONPATH
ENV PYTHONPATH=/usr/lib/python3.11:$PYTHONPATH
ENV PATH=/home/app/packages:${PATH}

WORKDIR /home/app
EXPOSE 8080
ENTRYPOINT ["python3.11", "/home/app/packages/gunicorn/app/wsgiapp.py", "main:app", "-c", "gunicorn_config.py"]


