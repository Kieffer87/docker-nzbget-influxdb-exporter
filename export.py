import os
import requests
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS

nzbget_username = os.getenv('NZBGET_USERNAME')
nzbget_password = os.getenv('NZBGET_PASSWORD')
nzbget_url = os.getenv('NZBGET_URL')
nzbget_url_ssl = os.getenv('NZBGET_URL_SSL')
nzbget_port = os.getenv('NZBGET_PORT')
nzbget_values_to_return = os.getenv('NZBGET_VALUES_TO_RETURN').split(',')

influxdb_token = os.getenv('INFLUXDB_TOKEN')
influxdb_org = os.getenv('INFLUXDB_ORG')
influxdb_url = os.getenv('INFLUXDB_URL')
influxdb_url_ssl = os.getenv('INFLUXDB_URL_SSL')
influxdb_port = os.getenv('INFLUXDB_PORT')
influxdb_bucket = os.getenv('INFLUXDB_BUCKET')

metrics_to_export = []


def get_nzb_status_metrics(api_endpoint):
    nzbget_endpoint = f'{nzbget_url_ssl}://{nzbget_username}:{nzbget_password}@{nzbget_url}:' \
                      f'{nzbget_port}/jsonrpc/{api_endpoint}'
    r = requests.get(nzbget_endpoint)
    result = r.json().get('result')
    for key in [key for key in result if key not in nzbget_values_to_return]: del result[key]
    return result


def get_influxdb_client():
    return InfluxDBClient(
        url=f'{influxdb_url_ssl}://{influxdb_url}:{influxdb_port}',
        token=influxdb_token,
        org=influxdb_org
    )


def write_to_influxdb():
    client = get_influxdb_client()

    write_api = client.write_api(write_options=SYNCHRONOUS, precision="s")
    metrics = get_nzb_status_metrics('status')

    for key in metrics:
        p = Point(key).field(key, metrics[key])
        write_api.write(bucket=influxdb_bucket, record=p)


def read_from_influxdb():
    client = get_influxdb_client()
    query_api = client.query_api()

    ## using Table structure
    tables = query_api.query(f'from(bucket:"{influxdb_bucket}") |> range(start: -10m)')

    for table in tables:
        print(table)
        for row in table.records:
            print(row.values)


if __name__ == '__main__':
    write_to_influxdb()
    read_from_influxdb()
