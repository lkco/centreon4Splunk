# centreon4Splunk
## Features
* Use stream connector to generate a log file "/var/log/centreon4splunk/centreon4splunk.log"
* Use Universal Forwarder to monitor this log
* All data are sending into centreon index
* Install and use centreon4splunk app to manipulate data

## Use stream connector feature into Centreon
* Copy lua script lua/centreon4splunk.lua to "/usr/share/centreon-broker/centreon4splunk.lua" on your Centreon server
* Run :
```
mkdir -p  /var/log/centreon4splunk && chown -R centreon-broker:centreon-broker /var/log/centreon4splunk
```
* Configure the new output into Centreon Web interface in "Configuration > Pollers > Broker configuration > Central Broker". 
* In Output tab select "Generic – Stream connector" and click "Add"
* Define the name of this output and the path to the Lua connector : /usr/share/centreon-broker/centreon4splunk.lua
* Click Save and go to generate the configuration and restart cbd daemon.


## Use Splunk Universal Forwarder
* Install and configure Universal Forwarder Splunk
*  Configure new sourcetype
```
[centreon4splunk]
DATETIME_CONFIG =
TZ = Europe/Paris
NO_BINARY_CHECK = true
SEDCMD-StripHeader = s/^.*INFO: (.*$)/\1/
TIME_PREFIX="log_time":
disabled = false
pulldown_type = true
description = centreon4splunk
```
* Add an input to monitore /var/log/centreon4splunk/centreon4splunk.log and use centreon4splunk sourcetype
* On your indexer, create a new index calling : centreon
* Deploy apps centreon4splunk in your Splunk server 
