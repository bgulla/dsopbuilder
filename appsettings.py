import json
from typing import DefaultDict
from collections import defaultdict
from util import streams
from rich.console import Console
console = Console()
import logging
import util.strings
from util import io

log_format = '%(asctime)s %(filename)s: %(message)s'
logging.basicConfig(filename='app.log', level=logging.DEBUG, format=log_format, datefmt='%Y-%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)

class AppSettings:
    def __init__(self):
        self.appsettings_file = './config/config.json'
        self.settings = {}
        self.read_appsettings()
    
    def print_settings_json(self):
        console.print_json(json.dumps(self.settings, indent=3))


    def read_appsettings(self):
        try:
            logger.debug("Read settings")
            with open(self.appsettings_file) as data_file:
                appsettings = json.load(data_file)
                self.settings = appsettings
                return self.settings
        except Exception as e:
            logger.error("Unable to open config.json")
            streams.cout_error(f"There was an error reading appsettings from: {self.appsettings_file}")
            streams.cout_error(e)

    def validate(self) -> bool:
        '''
            Validates the settings read from the config.json file
        '''
        is_valid = True
        rg = self.settings["general"]["cluster_name"]
        if (util.strings.validate_dsop_rg(rg) == False):
            is_valid = False
            io.cout_error("Invalid Cluster Name: Cluster names cannot contain special characters or '_'. Please edit config.json in the 'config' directory.")
        else:
            io.cout_success("Settings in config.json are Valid!")
            
        return is_valid

if __name__ == '__main__':
    _app = AppSettings()
    settings_dict = _app.read_appsettings()