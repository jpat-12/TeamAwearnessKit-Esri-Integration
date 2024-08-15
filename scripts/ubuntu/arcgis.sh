# Install & Activate Miniconda  
echo "Installing Miniconda..." 
cd /root
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda
cd /root/miniconda 
source /root/miniconda/bin/activate
conda init 
conda create -n arcgis_env python=3.9 

echo ""
echo "" 
echo "At this point you will need to close your current terminal/cmd prompt and start a new one."
echo ""
echo "We will continue the install by running the command below in the new terminal instance"
echo ""
echo "cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x arcgis2.sh && ./arcgis2.sh && cd /opt/TAK-Esri && ls -la"

