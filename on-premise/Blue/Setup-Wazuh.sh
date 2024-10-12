#!/bin/bash

curl https://packages.wazuh.com/4.9/wazuh-install.sh -o /tmp/wazuh-install.sh

curl https://packages.wazuh.com/4.9/config.yml -o /tmp/config.yml

sudo sed -i 's/<indexer-node-ip>/10.0.1.10/g' /tmp/config.yml

sudo sed -i 's/<wazuh-manager-ip>/10.0.1.10/g' /tmp/config.yml

sudo sed -i 's/<dashboard-node-ip>/10.0.1.10/g' /tmp/config.yml

bash /tmp/wazuh-install.sh --generate-config-files

bash /tmp/wazuh-install.sh --wazuh-indexer node-1

bash /tmp/wazuh-install.sh --start-cluster

bash /tmp/wazuh-install.sh --wazuh-server wazuh-1

bash /tmp/wazuh-install.sh --wazuh-dashboard dashboard

rm -rf /tmp/wazuh-install.sh