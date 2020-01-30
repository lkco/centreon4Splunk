# notify_centreon alert settings

action.notify_centreon = [0|1]
* Enable notify_centreon notification

action.notify_centreon.param.host = <string>
* Name of the host
* (required)

action.notify_centreon.param.service = <string>
* Name of the service linked host, to send notification alert
* (required)

action.notify_centreon.param.message = <string>
* The message to send to Status information for the service. 
* (required)

action.notify_centreon.param.status = [critical|warning|ok|unknown]
* Status to send
* (required)

action.notify_centreon.param.status_custom = [critical|warning|ok|unknown]
* Status to send
* (optional)
