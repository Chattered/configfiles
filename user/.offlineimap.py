#!/bin/python
import json
import os
import subprocess

def get_pass(account):
    try:
      gpg = os.getenv("GPG")
      out = subprocess.check_output(gpg + "/bin/gpg -d ~/.imappass.json.gpg", shell=True)
    except:
      exit(1)
    return json.loads(out)[account]
