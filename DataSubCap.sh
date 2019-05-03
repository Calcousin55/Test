#!/bin/sh
#
# DataSubCap v1.00 (04/02/2019)
#
# GitHub        - https://github.com/Calcousin55/DataSubCap
# Official Page - http://www.linksysinfo.org/index.php?posts//

#-------------------- Variables -----------------------

# Location where this script is kept
DataSubCapDir=$( cd $(dirname $0); pwd ) # Grabs current dir where script was ran

# Data cap base value
# (Base 2) Ki/Mi/Gi/Ti or (Base 10) k/m/g/t in bits (b) or bytes (B)
# Ex: GiB/Gib/gB/gb
DataCapBase="GiB"

# Cap limit to stop internet traffic when reached
# Make sure that the value is lower then your ISP data cap limit since there might will be a small amount of data being sent to the  
# router from the ISP and that when the internet traffic is stopped the data cap amount might be slightly over the limit set
DataCapLimit=295.0

# Display units in base 2 or 10
# 0 - Base 2  in bytes (GiB)
# 1 - Base 2  in bits  (Gib)
# 2 - Base 10 in bytes (gB)
# 3 - Base 10 in bits  (gb)
DisplayBase=0

# Option for types of ways to stop internet traffic once cap has been reached
# When a new month has been reached the internet traffic will be enabled again
# -- Options --
# 0=rules 1=iptables 2=service
# rules    - Uses the access restriction to block traffic of computers on the network (the router itself still uses data if its specific services are used "VPN/SSH/TOR/...")
# iptables - Uses the firewall to black all traffic except traffic between addresses in the allowed Nets variable like private address and/or other specified IPs
# service  - stop/start the wan service (Might get new external IP address) (If you are using a watchdog script, some watchdog scripts can restart the wan service re-allowing traffic)
DisableType=1

# ####### WARNING #######
# Test out iptables using the test option with the scheduler disable or with PersistantIptables=0 before using the
# scheduler or running the script with an offset or if already over the DataCapLimit to test stopping internet traffic
#
# If AllowedIPs doesn't have 127.0.0.1 then no devices can connect to the router
# If AllowedNets doesn't have the public addresses then the router will be inaccessable till the monthly reset with the following
#  - If PersistantIptables=0 then a router reboot will clear iptables allowing access again
#  - If PersistantIptables=1 and AllowedIPs or AllowedNets are set in a way that make the router inaccessable on the LAN then a hard reset 
#                            will need to be done or wait till the monthly reset to occur to get access again

# IPs addresses allowed to have traffic when using iptables
# 127.0.0.1      ( Routers home IP needed to allow devices to connect )
AllowedIPs="127.0.0.1"

# Net addresses allowed to have traffic when using iptables
# CIDR valid ranges are from 1-31
# The following IP nets are private address space not used for public addresses (WAN IPs from ISPs) which allow LAN traffic
# 10.0.0.0/8     (    10.0.0.0 - 10.255.255.255  )
# 172.16.0.0/12  (  172.16.0.0 - 172.31.255.255  )
# 192.168.0.0/16 ( 192.168.0.0 - 192.168.255.255 )
AllowedNets="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

# Reinitialize Iptables when changes are made or on a router reboot/power up
PersistantIptables=1

# Enable emailing
# Emails are send when any of the following criteria has been reached and their option is enabled
# * Percentage of data cap limit has been reached
# * Traffic is blocked or re-enabled
# * The router has rebooted
# 0=disabled 1=enabled
EmailLog=1

# Email a warning when the router has rebooted or when the script is first ran. If the router has rebooted the data
# statistics might have been reset or are off if data isn't saved to a permanent location or its save frequency is to
# long. The data recorded from there on might be less then the total data sent/received and there might be a potential
# to go over the data cap for the month. Use the offset option to get download data total to its correct value.
# 0=disabled 1=enabled
EmailReset=1

# Email the previous months statistics when a new month occurs
# 0=disabled 1=enabled
EmailMonthChange=1

# Data cap percentages to email when reached
# Decimal values 0-1 with spaces or commas between
# If 1.00 isn't used then no email will be sent when internet traffic is disabled
EmailThreshold="0.25 0.50 0.75 0.90 1.00"

# Note) smtp-cli needed for emailing data usage
