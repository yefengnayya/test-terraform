FROM python:rc-alpine3.14

WORKDIR /app
COPY ./app .

RUN pip install -r requirements.txt

CMD python main.py
