import json
import requests

from typing import Final
from urllib.parse import urlunparse, urlparse

LAKEKEEPER_DEMO_SCHEME: Final = "http"
LAKEKEEPER_DEMO_NET_LOCATION: Final = "lakekeeper:8181"

LAKEKEEPER_BOOTSTRAP_ROUTE: Final = "/management/v1/bootstrap"
LAKEKEEPER_BOOTSTRAP_ACCEPT_EULA_KEY: Final = "accept-terms-of-use"


bootstrap_url: str = urlunparse(
    urlparse(LAKEKEEPER_BOOTSTRAP_ROUTE)._replace(
        scheme=LAKEKEEPER_DEMO_SCHEME,
        netloc=LAKEKEEPER_DEMO_NET_LOCATION,
    ),
)


def make_bootstrap_request():
    bootstrap_response = requests.post(
        bootstrap_url,
        json={LAKEKEEPER_BOOTSTRAP_ACCEPT_EULA_KEY: True},
    )

    def _extract_error(r):
        return json.loads(r.content).get("error", {}).get("type", "")

    if (
        bootstrap_response.status_code == 400
        and _extract_error(bootstrap_response) == "CatalogAlreadyBootstrapped"
    ):
        print("Catalog already bootstrapped!")
    elif bootstrap_response.status_code == 204:
        print("Success!")
    else:
        print("Status unknown!")
        print(f"Status code: {bootstrap_response.status_code}")
        print(f"Response content: {bootstrap_response.content}")


if __name__ == "__main__":
    make_bootstrap_request()
    print("Goodbye!")
