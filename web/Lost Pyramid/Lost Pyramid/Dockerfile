# syntax=docker/dockerfile:1
FROM python:3.8-slim-buster
WORKDIR /app
COPY requirements.txt ./
RUN pip3 install -r requirements.txt
COPY ./ ./
ENV KINGSDAY="03_07_1341_BC"
ENV FLASK_APP="app.py"
EXPOSE 8050
CMD ["gunicorn", "-b", "0.0.0.0:8050", "-w 1", "app:app", "&"]
