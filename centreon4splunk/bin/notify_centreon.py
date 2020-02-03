# Copyright (C) 2020 Olivier LI-KIANG-CHEONG <lkco>
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#      http://www.apache.org/licenses/LICENSE-2.0
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

from __future__ import print_function
from future import standard_library
standard_library.install_aliases()
import sys
import os
import json
import time
from urllib.parse import urlencode
import urllib.request, urllib.error, urllib.parse
import requests
import logging
import logging.handlers


def log_msg(level):
    logger = logging.getLogger("notify_centreon")
    logger.propagate = False
    logger.setLevel(level)
    file_handler = logging.handlers.RotatingFileHandler(os.environ['SPLUNK_HOME'] + '/var/log/splunk/notify_centreon.log',maxBytes=104857600,backupCount=5)
    formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger

def get_status(i):
    switcher={
            "0":'OK',
            "1":'WARNING',
            "2":'CRITICAL',
            "3":'UNKNOWN',
    }
    return switcher.get(i,'Invalid')

def get_token(base_url,auth_login,auth_pass):
    request = requests.post(
        base_url + '/api/index.php?action=authenticate',
        data = {
                'username': auth_login,
                'password': auth_pass
        },
        verify = False
    )
    request.raise_for_status()
    auth_token = request.json()['authToken']
    return auth_token

def send_centreon(settings):
    base_url = settings.get('base_url')
    login = settings.get('login')
    password = settings.get('password')
    host = settings.get('host')
    service = settings.get('service')
    status_code = settings.get('status')
    message = settings.get('message')
    
    valid_status_code = "0","1","2","3"
    if status_code == "99":
        if settings.get('status_custom') in valid_status_code:
            status_code = settings.get('status_custom')
        else:
            status_code = "3"

    auth_token = get_token(base_url,login,password)
    headers={
        'Content-Type': 'application/json',
        'centreon-auth-token': auth_token
    }
    timenow = int(time.time())
    data = {
        "results": [{
            "output": get_status(status_code) + ': ' + message,
            "updatetime": timenow,
            "status": status_code,
            "service": service,
            "host": host
        }]
    }
        
    request = requests.post(
        base_url + '/api/index.php?action=submit&object=centreon_submit_results',
        headers = headers,
        verify = False,
        data = json.dumps(data)
    )
    logger.info('Sending data: ' + format(json.dumps(data)))
    request.raise_for_status()
    if 200 <= request.status_code < 300:
        #print("DEBUG receiver endpoint responded with HTTP status=%d" % request.status_code, file=sys.stderr)
        logger.info('Response: ' + format(json.dumps(request.json())))
        return True
    else:
        print("ERROR receiver endpoint responded with HTTP status=%d" % request.status_code, file=sys.stderr)
        return False

    data = request.json()

global logger
logger = log_msg(logging.INFO) 
if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] != "--execute":
        print("FATAL Unsupported execution mode (expected --execute flag)", file=sys.stderr)
        sys.exit(1)
    else:
        payload = json.loads(sys.stdin.read())
        settings = payload.get('configuration')
        #logger.info(format(json.dumps(payload)))
        logger.info('Configuration data: ' + format(json.dumps(settings)))
        if not send_centreon(settings):
            logger.info("ERROR Unable to contact centreon endpoint")
            sys.exit(2)
        else:
            logger.info("DEBUG centreon endpoint responded with OK status")
