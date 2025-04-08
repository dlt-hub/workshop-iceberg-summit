FROM python:3.11.11

WORKDIR /app

COPY ./src/bootstrap.py ./bootstrap.py
COPY ./src/create_lakekeeper_warehouse.py ./create_lakekeeper_warehouse.py
COPY ./src/create_bucket.py ./create_bucket.py
COPY ./src/pyiceberg_demo.py ./pyiceberg_demo.py
COPY ./src/main.py ./main.py
COPY ./requirements.txt ./requirements.txt

RUN pip install -r requirements.txt

CMD ["python", "./main.py"]
