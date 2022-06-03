This component handles peering between operational environments (such as dev, uat, live) and the account level environment containing build slaves, splunk forwarders, logicmonitor collectors etc.

It also associates the environmental DNS zones of each with the other's vpc to allow resolution i.e. it allows a client in the dev environment to resolve .ppd records and get their private IPs back

This component only needs to be run as part of the operational environment build - it handles both sides of the peering and DNS configurations