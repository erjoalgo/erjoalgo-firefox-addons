from os.path import exists, expanduser, isdir, join
from os import listdor

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-p", "--profile_dir",
                    help = "firefox profile directory")
parser.add_argument("-c", "--conf_file",
                    help = """addons list file, in the format
<addon-name-no-colon>: <addon-url>
                    """)

args=vars(parser.parse_args())
globals().update(args)

if not exists(profile_dir):
    top=expanduser("~/.mozilla/firefox")
    profile_cands=[isdir(fn) and re.match("[a-z0-9]+[.].*", basename(fn)) 
                   for fn in (join(top, fn) for fn in listdir(top))]
