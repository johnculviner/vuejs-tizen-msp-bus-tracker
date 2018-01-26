#!/usr/bin/env bash
cd tizen
rm BusTracker.wgt .manifest.tmp author-signature.xml signature1.xml #doesn't seem to work without some cleanup here
tizen clean
tizen build-web # build a web project
tizen package -t wgt -s JohnCulviner # package the widget using my signature stored elsewhere
tizen install -n BusTracker.wgt # install the widget on emulator attached to sdb
tizen run -p uk1A2xnaIo # run the app (has this name for now?)
sdb dlog ConsoleMessage:V # watch console output for javascript logs