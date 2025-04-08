from typing import Final

from minio import Minio
from minio.error import S3Error

LAKEKEEPER_DEMO_BUCKET_NAME: Final = "demo"


def create_bucket():
    client = Minio(
        "bucket:9000",
        access_key="minioadmin",
        secret_key="minioadmin",
        secure=False,
    )

    if not client.bucket_exists(LAKEKEEPER_DEMO_BUCKET_NAME):
        client.make_bucket(LAKEKEEPER_DEMO_BUCKET_NAME)
        print(f"Bucket {LAKEKEEPER_DEMO_BUCKET_NAME} created successfully!")
    else:
        print(f"Bucket {LAKEKEEPER_DEMO_BUCKET_NAME} already exists")


if __name__ == "__main__":
    try:
        create_bucket()
    except S3Error as exc:
        print("Encountered error while creating bucket")
        print(exc)

    print("Goodbye!")
