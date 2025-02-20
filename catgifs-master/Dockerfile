FROM alpine:latest
RUN apk add --update py3-pip
COPY requirements.txt /usr/src/app/
# Install system dependencies and Python virtual environment
RUN apk add py3-virtualenv \
    && python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip
RUN /opt/venv/bin/pip install --no-cache-dir -r /usr/src/app/requirements.txt
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt
COPY app.py /usr/src/app/
COPY templates/index.html /usr/src/app/templates/
COPY static/styles/main.css /usr/src/app/static/styles/
COPY static/images/* /usr/src/app/static/images/
EXPOSE 5000
CMD ["python", "/usr/src/app/app.py"]
