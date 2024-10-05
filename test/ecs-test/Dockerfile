FROM python:alpine3.20

WORKDIR /app

COPY src .

RUN pip install -r requirements.txt

EXPOSE 8000

ENTRYPOINT ["python", "main.py"]
