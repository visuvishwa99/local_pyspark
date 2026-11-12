# Local AWS Glue 5 + JupyterLab

Local practice environment using official AWS Glue 5 image. Includes:

- AWS Glue 5 runtime
- Spark 3.5.4 (AWS build)
- PySpark and Glue libraries
- JupyterLab 4.6.6
- Live Spark Web UI
- Repository folder mounted at `/home/hadoop/workspace`

## Requirements

- Docker Desktop running with Linux containers
- About 12 GB for base Glue image, plus small Jupyter layer
- VS Code Jupyter extension if connecting from VS Code

## Start

Clone repo and start from PowerShell:

```powershell
git clone https://github.com/visuvishwa99/local_pyspark.git
cd local_pyspark
$env:JUPYTER_TOKEN = "choose-a-local-token"
docker compose up --build -d
```

If old manually-created `glue-pyspark` container exists, remove it once before starting Compose:

```powershell
docker stop glue-pyspark
docker rm glue-pyspark
docker compose up --build -d
```

Removing container does not remove project files because repository folder is mounted from Windows.

## Open JupyterLab

```text
http://127.0.0.1:8888/?token=choose-a-local-token
```

If `JUPYTER_TOKEN` was not set, default local token is `glue-local`:

```text
http://127.0.0.1:8888/?token=glue-local
```

### How the token works

`JUPYTER_TOKEN` is a local Jupyter authentication token. It is not an AWS credential, GitHub token, or API key. You choose it before starting Compose:

```powershell
$env:JUPYTER_TOKEN = "choose-a-local-token"
docker compose up -d
```

Docker Compose passes that value into the container, and Jupyter requires it when a browser or VS Code connects. To see the configured token:

```powershell
docker compose exec glue-pyspark printenv JUPYTER_TOKEN
```

To change it, set a new value and recreate the container:

```powershell
$env:JUPYTER_TOKEN = "new-local-token"
docker compose up -d --force-recreate
```

Do not commit real secrets in `.env`; this repository ignores `.env`. Ports bind to `127.0.0.1`, so Jupyter and Spark UI are not exposed to other machines.

## Connect VS Code notebook

1. Install VS Code **Jupyter** extension.
2. Open or create an `.ipynb` file.
3. Select **Kernel** → **Existing Jupyter Server**.
4. Enter:

```text
http://127.0.0.1:8888/?token=choose-a-local-token
```

5. Select `Python 3` kernel.

## Start Spark and Glue context

Run this as first notebook cell:

```python
from pyspark.context import SparkContext
from awsglue.context import GlueContext

sc = SparkContext.getOrCreate()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

print(spark.version)
spark.range(5).show()
```

Spark UI becomes available after SparkContext starts:

```text
http://127.0.0.1:4040
```

Spark UI shows live Jobs, Stages, SQL, Storage, Environment, and Executors. Keep notebook kernel running. Stopping SparkContext removes live UI.

## Run Python scripts

```powershell
docker compose exec glue-pyspark spark-submit /home/hadoop/workspace/path/to/job.py
```

Open container shell:

```powershell
docker compose exec glue-pyspark bash -l
```

## Lifecycle

```powershell
# Show logs
docker compose logs -f

# Stop container, preserve it
docker compose stop

# Start again
docker compose start

# Remove container; mounted project files remain
docker compose down

# Rebuild after Dockerfile changes
docker compose up --build -d
```

## Notes

- Jupyter installation belongs to custom image, so recreating container keeps it.
- Notebook and project files should stay under `/home/hadoop/workspace`.
- Spark UI is live-only. Completed applications need separate Spark History Server setup.
- AWS credentials are not required for local DataFrame practice. AWS service access requires mounting credentials and configuring profile/region.
