# Demonstrating PyIceberg + LakeKeeper

## Run Demo

```sh
docker compose --project-name iceberg_demo up -d
docker run --network iceberg_demo_iceberg_net --rm -it $(docker build -q .)
```

## See UIs

- To see the LakeKeeper UI, navigate to the url: [`http://localhost:8181`](http://localhost:8181)

- To see the Minio (S3) UI, navigate to the url: [`http://localhost:9001`](http://localhost:9001)

  - Username: `minioadmin`

  - Password: `minioadmin`

## Cleanup Demo

```sh
docker compose down -v
docker image prune
docker volume prune
```

