# pip install influxdb-client
import influxdb_client
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

import os
import time
import random
import json

# for file in same dir
from pathlib import Path
from datetime import datetime, timezone


class RunInflux:

    def __init__(self):
        self.ip = None
        self.token = None
        self.bucket = None
        self.org = None
        self.url = None
        self.client = None
        self.read_config()

    def read_config(self):
        with open("config.json") as f:
            data = json.load(f)
            for d in data["connection_information"]:
                self.ip = d["ip"]
                self.token = d["token"]
                self.bucket = d["bucket"],
                self.org = d["organization"]
            # print(data)

    def write_client(self):
        # url = "http://" + str(self.ip) + ":8086"
        url_tls = "https://" + str(self.ip) + ":8086"
        print("Try write data, fetch a client for influxdb")
        print(self.bucket)
        print(self.org)
        try:
            # for ssl full add ssl_ca_cert=
            self.client = influxdb_client.InfluxDBClient(url=url_tls, token=self.token, org=self.org, verify_ssl=False)
            print(self.client)
            write_api = self.client.write_api(write_options=SYNCHRONOUS)
            for x in range(200):
                dt = datetime.now(timezone.utc)
                #  bucket = str(self.bucket)
                bucket = "bucketTemperature"
                ran1 = random.uniform(10.5, 35.9)
                ran2 = ran1 + 5
                point_brg = (Point("Tag-BRG").tag("location", "Bergen").field("temperature", ran1).time(dt))
                point_osl = (Point("Tag-OSL").tag("location", "Oslo").field("temperature", ran2).time(dt))

                write_api.write(bucket=bucket, org=self.org, record=point_brg)
                write_api.write(bucket=bucket, org=self.org, record=point_osl)

                time.sleep(5)
                print("Write Tag-BRG " + str(ran1) + " and Tag-OSL " + str(ran2) + " " + str(dt))
        except Exception as ex:
            print(ex)
        return self.client




if __name__ == "__main__":
    runner = RunInflux()
    runner.write_client()