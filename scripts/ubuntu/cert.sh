#!/bin/bash



# Changing directory so we can run ./makeCert.sh
cd /opt/tak/certs/
ls 
echo "Running as TAK user"

echo "Creating Cert Named NodeRed" 

# If user input of $cert_name is empty than use default 

# Make Cert
cd /opt/tak/certs
./makeCert.sh client NodeRed
echo "Client Cert NodeRed has been created"
chown tak:tak /opt/tak/certs/files
sleep 3

# Restart Takserver
echo ""
echo ""
echo "Restarting TAKServer" 
echo ""
echo ""
service takserver restart
clear

# Editing $cert_name so it can be used later in node red
echo "Changing NodeRed for NodeRed" 
sleep 2
cd /opt/tak/certs/files
clear 
echo "default password "atakatak""
sleep 2

# Make cert.pem 
openssl pkcs12 -clcerts -nokeys -in NodeRed.p12 -out NodeRed.cert.pem

# Make key.pem
openssl pkcs12 -nocerts -nodes -in NodeRed.p12 -out NodeRed.key.pem
