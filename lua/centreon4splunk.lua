--[[
 Copyright (C) 2018 Olivier LI-KIANG-CHEONG <lkco>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along
 with this program; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
  end

  -- BA Status
  if ( d.category == 6 and d.element == 1 ) then
    data["element"]               = d.element
    data["category"]              = d.category
    data["state"]                 = d.state
    data["level_nominal"]         = d.level_nominal
    data["ba_id"]                 = d.ba_id
    data["ba_name"]               = broker_cache:get_ba(d.ba_id)
    broker_log:info(3, broker.json_encode(data))
    return true
  end

  -- Event handler
  if ( d.category == 1 and d.element == 6 ) then
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
    -- Replace blackslash by underscore
    local output
    output = string.gsub(d.output,'\\',"_")
    data["output"]                = output

    data["state"]                 = d.state
    data["state_type"]            = d.state_type
    data["log_time"]              = d.start_time
    broker_log:info(3, broker.json_encode(data))
    return true
  end

  -- Host Status
  if (d.category == 1 and d.element == 14 ) then
    data["hostname"]              = broker_cache:get_hostname(d.host_id)
    data["hostgroups"]            = broker_cache:get_hostgroups(d.host_id)
    data["acknowledged"]          = d.acknowledged
    data["acknowledgement_type"]  = d.acknowledgement_type
    data["category"]              = d.category
    data["check_command"]         = d.check_command
    data["element"]               = d.element
    data["event_handler"]         = d.event_handler
    data["event_handler_enabled"] = d.event_handler_enabled
    local output
    output = string.gsub(d.output,'\\',"_")
    data["output"]                = output
    data["state"]                 = d.state
    data["state_type"]            = d.state_type
    data["log_time"]              = d.last_check
    broker_log:info(3, broker.json_encode(data))
    return true

  end

  -- Service Status
  if ( d.category == 1 and d.element == 24 ) then
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
    local output
    output = string.gsub(d.output,'\\',"_")
    data["output"]                = output
    data["state"]                 = d.state
    data["state_type"]            = d.state_type
    data["log_time"]              = d.last_check
    broker_log:info(3, broker.json_encode(data))
    return true
  end

  -- Log Entry
  if ( d.category == 1 and d.element == 17 ) then
    if d.host_id then
      data["hostname"]              = broker_cache:get_hostname(d.host_id)
      data["hostgroups"]            = broker_cache:get_hostgroups(d.host_id)
      if d.service_id then
        data["service_description"]   = broker_cache:get_service_description(d.host_id,d.service_id)
      end
    end
    data["category"]              = d.category
    data["element"]               = d.element

    -- Replace blackslash by underscore
    local output
    output = string.gsub(d.output,'\\',"_")

    data["output"]                = output
    data["state"]                 = d.status
    data["retry"]                 = d.retry
    data["instance_name"]         = d.instance_name
    data["notification_contact"]  = d.notification_contact
    data["log_time"]              = d.ctime

    broker_log:info(3, broker.json_encode(data))
    return true
  end

  -- Metric
  if (d.category == 3 and d.element == 1) then
    -- Replace blackslash by underscore
    local name
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
