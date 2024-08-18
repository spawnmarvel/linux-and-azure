import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS
import time
import random

bucket = "myBucket"
org = "myOrg"
token = "randomTokenValue"
# Store the URL of your InfluxDB instance
url="http://172.27.0.2:8086"

client = influxdb_client.InfluxDBClient(
    url=url,
    token=token,
    org=org
)


# Write script
write_api = client.write_api(write_options=SYNCHRONOUS)

for x in range(200):
    ran1 = random.uniform(10.5, 35.9)
    b = influxdb_client.Point("my_measurement").tag("location", "Bergen").field("temperature", ran1)
    write_api.write(bucket=bucket, org=org, record=b)
    o = influxdb_client.Point("my_measurement").tag("location", "Oslo").field("temperature", (ran1+5))
    write_api.write(bucket=bucket, org=org, record=o)
    print("inserted " + str(ran1))
    time.sleep(5)