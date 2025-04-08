from bootstrap import make_bootstrap_request
from create_bucket import create_bucket
from create_lakekeeper_warehouse import create_lakekeeper_warehouse
from pyiceberg_demo import demo


def main():
    make_bootstrap_request()
    create_bucket()
    create_lakekeeper_warehouse()
    # demo()


if __name__ == "__main__":
    main()
