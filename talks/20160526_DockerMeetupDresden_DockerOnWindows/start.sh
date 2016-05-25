#!/bin/bash
python -m SimpleHTTPServer 8000 &
sleep 1
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --kiosk http://localhost:8000
