# 🏗️ Lakehouse Architecture with Iceberg

Welcome to your deep dive into the world of Lakehouses with Apache Iceberg! 🚢❄️

In this hands-on workshop, we’ll build our own mini data lakehouse. We’ll be ingesting data from a REST API, writing it into Iceberg tables, and exploring how everything is tied together with a catalog. Let’s go! 🧙‍📊

## 🚀 Step 0: Prep your environment

In this workshop we'll be using [uv](https://github.com/astral-sh/uv) package manager for managing the Python 
environment. It's a fast Python package and project manager, written in Rust. 

If you don’t have it yet, install it with:

```shell
pip install uv
```
or

```shell
# On macOS and Linux.
curl -LsSf https://astral.sh/uv/install.sh | sh
# On Windows.
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Once that’s done, setting up your whole dev environment is as simple as:
```shell
make dev
```

❗ Don't have `make`? No worries – just run the full installation command below:
```shell
uv sync --reinstall-package dlt --upgrade-package dlt --reinstall-package dlt-plus --upgrade-package dlt-plus --all-extras --group dev --no-managed-python
```

## 🛫 Step 1: Bring in some data

Let’s start ingesting data into our data lake! 🎉

But before we jump into configuring our API source, here's a quick intro to what kind of project we’re actually working with.

### 🧩 What is a dlt+ Project?
This workshop is powered by a dlt+ Project, which gives you a declarative and structured way to build data workflows. 
Instead of jumping between scripts and configs, everything lives in one clear place – the `dlt.yml` manifest file. 
Think of it as your project’s single source of truth for data sources, pipelines, destinations, and transformations. 📘✨

The project layout includes:

* 📄 dlt.yml – the heart of your project, defining all key data entities
* 📁 .dlt/ – holds secrets and metadata (like credentials), fully compatible with OSS dlt
* 💾 _data/ – used for pipeline state and local files (automatically excluded from Git)

Now that you're familiar with the structure, let’s put it into action by defining our first data source!

We’ll be using the famous [jaffle-shop](https://github.com/dbt-labs/jaffle-shop) dataset – a mock e-commerce store that’s perfect for data modeling fun.
We created a REST API just for this workshop (you're welcome 😉).

* 📚 Check out the auto-generated API docs here:
👉 [API docs](https://fast-api-jaffle-shop-jz2mh.ondigitalocean.app/docs)
* More context on the project:
👉 [GitHub Repo](https://github.com/dlt-hub/fast-api-jaffle-shop)
* The API url:
👉https://jaffle-shop.dlthub.com/api/v1

Let’s set up our source inside the `dlt_portable_data_lake_demo/dlt.yml` file. You'll see a `sources` section with a `jaffle_shop` placeholder. Your job is to fill in the missing bits.

### ✏️ Exercise 1: Complete the source config

Use the API [docs](https://fast-api-jaffle-shop-jz2mh.ondigitalocean.app/docs) to fill in the correct values: 

```yaml
  jaffle_shop:
    type: rest_api
    client:
      base_url: # Insert API base URL here
      paginator: auto
    resource_defaults:
      write_disposition: replace
    resources:
      - customers
      - # Add up to 4 more bulk endpoints
      -
        name: orders
        endpoint:
          path: orders
          params:
            start_date:
              type: incremental
              cursor_path: # What field in the response contains the timestamp? 
        write_disposition: append
```

## 🧊 Step 2: Connect to iceberg

We’re setting up our destination as Apache Iceberg – a table format that brings data lake magic to your files! 
For starters, to make things easier, we’ll keep it local: Iceberg tables will be located on disk, and an SQLite database will be used as a catalog.

Here's the destination config in `dlt.yml`:

```yaml
destinations:
  iceberg_lake:
    type: iceberg
    catalog_type: sql
```

We put some additional configuration specific for our setup into 
```yaml
profiles:
  dev: &dev_profile
    destinations:
      iceberg_lake:
        credentials:
          drivername: sqlite
          database: catalog.db
        capabilities:
          register_new_tables: true
        filesystem:
          bucket_url: raw_data
```
This will make it easier to switch to any other configuration.

And now, define your pipeline! This is what moves the data from source to destination:
```yaml
pipelines:
  api_to_lake:
    source: jaffle_shop
    destination: iceberg_lake
    dataset_name: jaffle_shop_dataset
    progress: log
```
Nice! We're all set to get data flowing 

## ▶️ Step 3: Run the pipeline

Time to load some data! Just run the following command:

```shell
uv run dlt pipeline api_to_lake run --limit 2
```
What’s happening here:
- `uv run` - is needed for every command we're using to utilize our environment
- `dlt pipeline <pipeline_name> run` - will run our pipeline
- `--limit 2` - will help us to keep things fast. It will limit our requests for each endpoint by only 2. 
If you want to load all available data, you can remove this option, but this will take a while.

### ✏️ Exercise 2: Kick off your first load

After running this command you should see the following output:

```shell
1 load package(s) were loaded to destination iceberg_lake and into dataset jaffle_shop_dataset
The iceberg_lake destination used sqlite:////Users/vmishechk/PycharmProjects/dlt-portable-data-lake-demo/dlt_portable_data_lake_demo/_data/dev/local/catalog.db location to store data
```

### ✏️ Exercise 3: Look at the results

To look at the ingested data use the following command:

```shell
uv run dlt pipeline api_to_lake show
```

🧠 Question: How many `stores` are present in a data? 

## 🔬 Step 4: Inspect what we got

Let’s explore the files! Head to `dlt_portable_data_lake_demo/_data/dev/local` and you’ll see a beautiful structure: each endpoint has its own folder with Parquet files and metadata.

Our catalog (a simple SQLite DB) knows where everything lives. To inspect catalog and data, let’s launch a Jupyter Notebook!

1. First, register your environment as a Jupyter kernel:
```shell
uv run python -m ipykernel install --user --name .venv --display-name "uv kernel"
```

2. Then, run:

```shell
uv run jupyter notebook
```

3. Open `notebooks/workshop.ipynb` and start exploring 🚀

## ☁️ Step 5 [Advanced]: Go production-grade with Lakekeeper

🎉 You’ve made it this far – you've ingested data, stored it in Iceberg tables, explored it locally, and gotten familiar 
with how to get access to your data with the help of DuckDB in a hands-on way. 
But so far, we've been playing in a local sandbox: storing data on your machine and using a lightweight SQLite database as our catalog. 
That’s perfect for development and testing – but what about the real world?

In production, you’d want to:

* Store your data on scalable, durable cloud storage (like S3, Azure Blob, or GCS)
* Use a robust Iceberg catalog service to track your datasets (Lakekeeper, Dremio, AWS Glue, Nessie, Polaris)
* Share and query data across teams, tools, and environments with zero hassle

That’s where Lakekeeper comes in – an open-source, production-grade Iceberg catalog. It’s easy to set up, plays well with any cloud storage, and lets you build real 
data platforms without needing to set up heavy-duty infrastructure.

In this step, we’ll show you how to:

* Configure a new destination profile that uses Lakekeeper as the catalog
* Launch a local Lakekeeper + MinIO instance with Docker
* Load data into a real Iceberg lake backed by cloud-like storage ✨

This is your "from dev to prod" moment. Let’s get your lakehouse production-ready! 💪🏽🌊

Here’s how to define a new `prod` profile in `dlt.yml`:

```yaml
profiles:
  prod:
    destinations:
      iceberg_lake:
        catalog_type: rest
        credentials:
          uri: http://localhost:8181/catalog
          warehouse: demo_wh
        capabilities:
          # where on s3 tables will be created. note that this must match bucket and key prefix on Lakekeeper
          # you may also use absolute uri: including s3://bucket
          table_location_layout: "s3://demo/new_location/lakekeeper_demo_4/{dataset_name}/{table_name}"
```

✨ Note: The data location is handled by Lakekeeper – all you provide is access to the Lakekeeper. In real-world 
use-case you will also provide an access token to Lakekeeper. You can put it to `.dlt/secrets.toml`.

### 🛠️ Let’s Spin Up Lakekeeper + Minio

We’ll use a prebuilt playground. Type in your terminal:
```shell
cd lakekeeper_playground
docker compose --project-name iceberg_demo up -d
```

It could take some time. Once that’s ready, run this helper script to set up a demo S3 bucket and link it to Lakekeeper:

```shell
docker run --network iceberg_demo_iceberg_net --rm -it $(docker build -q .)
```

Now you can access both Lakekeeper UI and Minio:

- To see the LakeKeeper UI, navigate to the url: [`http://localhost:8181`](http://localhost:8181)

- To see the Minio (S3) UI, navigate to the url: [`http://localhost:9001`](http://localhost:9001)

  - Username: `minioadmin`
  - Password: `minioadmin`

### 🐳 Docker shenanigans

Because Docker uses an internal network, accessing the MinIO bucket from your host (using the S3-style URL provided by Lakekeeper) needs a little trick.
You’ll need to add an alias so that bucket resolves to your local machine:

* on Windows: open `C:\Windows\System32\drivers\etc\hosts` as Administrator and add
```text
127.0.0.1 bucket
```
* on Mac / Linux: run `sudo nano /etc/hosts`, add the line
```text
127.0.0.1 bucket
```
This lets your system resolve S3-style requests like http://bucket:9000 back to MinIO running on localhost.

### Run the pipeline

Finally, run your pipeline with the new profile:

```shell
uv run dlt pipeline --profile prod api_to_lake run --limit 2
```

## 🧠 Step 6 [Pro]: Run SQL Workflows with dbt

So far, you've built a complete data pipeline from scratch:
✅ You ingested data from an API
✅ Stored it in Iceberg tables
✅ Explored it with SQL, Ibis, and pandas
✅ Even scaled things up with a production-grade catalog

But we’ve almost skipped one big piece of the modern data platform puzzle... 🧩 analytics and reporting!

And that’s where dbt comes into play. If you're not familiar, dbt lets you define SQL models (i.e. transformations) using version-controlled, modular queries – and it’s become the go-to tool for data teams worldwide.

### 💡 So how do you run dbt models on Iceberg?
Here’s the magic: since DuckDB can create views over your Iceberg tables, you can treat them just like any regular SQL tables. That means you can write dbt models on top of your Iceberg lake, and run them locally with fast DuckDB execution. ⚡

Even better – once your transformations are done, you can push the results to any modern data warehouse (like Snowflake, BigQuery, Redshift). Or wherever your analytics live!
This means you can build efficient, low-cost data pipelines with Iceberg + DuckDB + dbt, and only push your final curated datasets to your warehouse for BI or ML use cases. It’s the best of both worlds.

### ⚙️ Let's run the transformations
We’ve prepared a ready-to-go dbt project and config for dlt+ Project which includes transformations. Replace your current `dlt.yml` with the contents of `dlt_manifest_full.yml`.
This enables dlt+ Cache, which auto-creates a DuckDB layer for your dbt models.

Then run the following command:

```shell
uv run dlt transformation get_reports run
```
This will run the pre-configured dbt models and generate reporting tables on top of your Iceberg data lake.

If you want to take a look at your fresh dbt tables, run the jupyter notebook again:
```shell
uv run jupyter notebook
```
Then open `notebooks/workshop.ipynb` and scroll to the last section. 

### 📘 More information

If you’re curious to explore this step more, check out the guide:
👉 [Running Transformations with dlt+](https://dlthub.com/docs/plus/features/transformations/setup)

This covers:

* How dlt+ automatically spins up a DuckDB cache for your models
* How to configure dbt to run against that cache
* And how to export your final datasets to your favorite cloud platform

✨ This is your gateway into modern ELT workflows, combining open formats (Iceberg), high-performance compute (DuckDB), and powerful modeling (dbt). You’re ready to join the big leagues 🏆
