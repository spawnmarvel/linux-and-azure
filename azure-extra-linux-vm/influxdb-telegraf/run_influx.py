# pip install influxdb-client
import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS
import time
import random
import json

# for file in same dir
from pathlib import Path

class RunInflux:

    def __init__(self):
        self.ip = None
        self.token = None

    def read_config(self):
        with open("config.json") as f:
            data = json.load(f)
            for d in data["connection_information"]:
                print(d["ip"])
                print(d["token"])


if __name__ == "__main__":
    runner = RunInflux()
    runner.read_config()
