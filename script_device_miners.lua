-- demo device script
-- script names have three name components: script_trigger_name.lua
-- trigger can be 'time' or 'device', name can be any string
-- domoticz will execute all time and device triggers when the relevant trigger occurs
-- 
-- copy this script and change the "name" part, all scripts named "demo" are ignored. 
--
-- Make sure the encoding is UTF8 of the file
--
-- ingests tables: devicechanged, otherdevices,otherdevices_svalues
--
-- device changed contains state and svalues for the device that changed.
--   devicechanged['yourdevicename']=state 
--   devicechanged['svalues']=svalues string 
--
-- otherdevices and otherdevices_svalues are arrays for all devices: 
--   otherdevices['yourotherdevicename']="On"
--	otherdevices_svalues['yourotherthermometer'] = string of svalues
--
-- Based on your logic, fill the commandArray with device commands. Device name is case sensitive. 
--
-- Always, and I repeat ALWAYS start by checking for the state of the changed device.
-- If you would only specify commandArray['AnotherDevice']='On', every device trigger will switch AnotherDevice on, which will trigger a device event, which will switch AnotherDevice on, etc. 
--
-- The print command will output lua print statements to the domoticz log for debugging.
-- List all otherdevices states for debugging: 
--   for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging: 
--   for i, v in pairs(otherdevices_svalues) do print(i, v) end
--
-- TBD: nice time example, for instance get temp from svalue string, if time is past 22.00 and before 00:00 and temp is bloody hot turn on fan. 

commandArray = {}

if (devicechanged['Temperature (Office)']) then
	temp = tonumber(otherdevices['Temperature (Office)'])
	target = tonumber(otherdevices['Thermostat'])
	print('Temperature Office: ' .. temp)

	if (temp >= target + 1.0) then
		level = '0'
		name = 'Off'
	elseif (temp >= target + 0.8) then
		level = '10'
		name = 'G1'
	elseif (temp >= target + 0.6) then
		level = '20'
		name = 'G2'
	elseif (temp >= target + 0.4) then
		level = '30'
		name = 'G3'
	elseif (temp >= target + 0.2) then
		level = '40'
		name = 'G4'
	elseif (temp >= target) then
		level = '50'
		name = 'G5'
	else
		level = '60'
		name = 'G6'
	end

	if(otherdevices['Miner (Office)'] ~= name) then
		commandArray['Miner (Office)'] = 'Set Level: ' .. level
		print('Switching Miner (Office) from ' .. otherdevices['Miner (Office)'] .. ' to ' .. name)
	end
end

if (devicechanged['Temperature (Living)']) then
	temp = tonumber(otherdevices['Temperature (Living)'])
	target = tonumber(otherdevices['Thermostat'])
	print('Temperature Living: ' .. temp)

	if (temp >= target + 1.0) then
		level = '0'
		name = 'Off'
	elseif (temp >= target + 0.8) then
		level = '10'
		name = 'G1'
	elseif (temp >= target + 0.6) then
		level = '20'
		name = 'G2'
	elseif (temp >= target + 0.4) then
		level = '30'
		name = 'G3'
	elseif (temp >= target + 0.2) then
		level = '40'
		name = 'G4'
	elseif (temp >= target) then
		level = '50'
		name = 'G5'
	else
		level = '60'
		name = 'G6'
	end

	if(otherdevices['Miner (Living)'] ~= name) then
		commandArray['Miner (Living)'] = 'Set Level: ' .. level
		print('Switching Miner (Living) from ' .. otherdevices['Miner (Living)'] .. ' to ' .. name)
	end
end

return commandArray
