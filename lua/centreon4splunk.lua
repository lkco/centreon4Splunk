#!/usr/bin/lua
--[[
 Copyright (C) 2020 Olivier LI-KIANG-CHEONG <lkco>

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 Version : 1.0
 Author : Olivier LI-KIANG-CHEONG <lkco@gezen.fr>

--]]


function init(conf)
  broker_log:set_parameters(3, "/var/log/centreon4splunk/centreon4splunk.log")
end


function write(d)
  local data = {}
  -- Downtime
  if ( d.category == 1 and d.element == 5 ) then
    if d.host_id then
      d["hostname"]              = broker_cache:get_hostname(d.host_id)
      d["hostgroups"]              = broker_cache:get_hostgroups(d.host_id)
      if d.service_id then
        d["service_description"]   = broker_cache:get_service_description(d.host_id,d.service_id)
      end
    end

    data["log_time"]            = d.entry_time
    broker_log:info(3, broker.json_encode(d))
    return true

  -- BA Status
  elseif ( d.category == 6 and d.element == 1 ) then
    data["element"]               = d.element
    data["category"]              = d.category
    data["state"]                 = d.state
    data["level_nominal"]         = d.level_nominal
    data["ba_id"]                 = d.ba_id
    data["ba_name"]               = broker_cache:get_ba(d.ba_id)
    broker_log:info(3, broker.json_encode(data))
    return true

  -- Event handler 
  elseif ( d.category == 1 and d.element == 6 ) then
    if d.host_id then
      data["hostname"]              = broker_cache:get_hostname(d.host_id)
      if d.service_id then
        data["service_description"]   = broker_cache:get_service_description(d.host_id,d.service_id)
      end
    end
    data["hostname"]              = broker_cache:get_hostname(d.host_id)
    data["service_description"]   = broker_cache:get_service_description(d.host_id,d.service_id)
    data["category"]              = d.category
    data["command_args"]          = d.command_args
    data["command_line"]          = d.command_line
    data["element"]               = d.element
    local output
    -- Replace blackslash by underscore
    output = string.gsub(d.output,'\\',"_")
    data["output"]                = output
    data["state"]                 = d.state
    data["state_type"]            = d.state_type
    data["log_time"]              = d.start_time
    broker_log:info(3, broker.json_encode(data))
    return true

  -- Host Status
  elseif (d.category == 1 and d.element == 14 ) then 
    data["hostname"]              = broker_cache:get_hostname(d.host_id)
    data["hostgroups"]            = broker_cache:get_hostgroups(d.host_id)
    data["acknowledged"]          = d.acknowledged
    data["acknowledgement_type"]  = d.acknowledgement_type
    data["category"]              = d.category
    data["check_command"]         = d.check_command
    data["element"]               = d.element
    data["event_handler"]         = d.event_handler
    data["event_handler_enabled"] = d.event_handler_enabled
    data["execution_time"]        = d.execution_time
    local output
    -- Replace blackslash by underscore
    output = string.gsub(d.output,'\\',"_")
    data["output"]                = output
    data["state"]                 = d.state
    data["state_type"]            = d.state_type
    data["log_time"]              = d.last_check
    broker_log:info(3, broker.json_encode(data))
    return true


  -- Service Status
  elseif ( d.category == 1 and d.element == 24 ) then
    data["hostname"]              = broker_cache:get_hostname(d.host_id)
    data["hostgroups"]            = broker_cache:get_hostgroups(d.host_id)
    data["service_description"]   = broker_cache:get_service_description(d.host_id,d.service_id)
    data["acknowledged"]          = d.acknowledged
    data["acknowledgement_type"]  = d.acknowledgement_type
    data["category"]              = d.category
    data["check_command"]         = d.check_command
    data["check_period"]          = d.check_period
    data["element"]               = d.element
    data["event_handler"]         = d.event_handler 
    data["event_handler_enabled"] = d.event_handler_enabled
    data["execution_time"]        = d.execution_time
    local output
    -- Replace blackslash by underscore
    output = string.gsub(d.output,'\\',"_")
    data["output"]                = output
    data["state"]                 = d.state
    data["state_type"]            = d.state_type
    data["log_time"]              = d.last_check
    broker_log:info(3, broker.json_encode(data))
    return true

  -- Log Entry
  elseif ( d.category == 1 and d.element == 17 ) then
    if d.host_id then
      data["hostname"]              = broker_cache:get_hostname(d.host_id)
      data["hostgroups"]            = broker_cache:get_hostgroups(d.host_id)
      if d.service_id then
        data["service_description"]   = broker_cache:get_service_description(d.host_id,d.service_id)
      end
    end
    data["category"]              = d.category
    data["element"]               = d.element
    local output
    -- Replace blackslash by underscore
    output = string.gsub(d.output,'\\',"_")
    data["output"]                = output
    data["state"]                 = d.status
    data["retry"]                 = d.retry
    data["instance_name"]         = d.instance_name
    data["notification_contact"]  = d.notification_contact
    data["notification_cmd"]      = d.notification_cmd
    data["instance_name"]         = d.instance_name
    
    data["log_time"]              = d.ctime
    
    broker_log:info(3, broker.json_encode(data))
    return true

  -- Metric
  elseif (d.category == 3 and d.element == 1) then
    local name
    -- Replace blackslash by underscore
    name = string.gsub(d.name,'\\',"_")
    data["hostname"]              = broker_cache:get_hostname(d.host_id)
    data["service_description"]   = broker_cache:get_service_description(d.host_id,d.service_id)
    data["metric"]                = name
    data["value"]                 = d.value
    data["log_time"]              = d.ctime
    broker_log:info(3, broker.json_encode(data))
    return true
  end
  
  return true

end
