echo "┏━━━┓ ┏━━━┓ ┏━━━┓ ┏┓︱┏┓ ┏━━┓︱ ┏━━━┓ ┏━━━┓ ┏━━━┓ ┏━━━┓ ┏━━━┓ ┏┓︱︱┏┓"
echo "┗┓┏┓┃ ┃┏━┓┃ ┃┏━┓┃ ┃┃︱┃┃ ┃┏┓┃︱ ┃┏━┓┃ ┃┏━┓┃ ┃┏━┓┃ ┗┓┏┓┃ ┃┏━┓┃ ┃┗┓┏┛┃"
echo "︱┃┃┃┃ ┃┃︱┃┃ ┃┗━━┓ ┃┗━┛┃ ┃┗┛┗┓ ┃┃︱┃┃ ┃┃︱┃┃ ┃┗━┛┃ ︱┃┃┃┃ ┃┗━━┓ ┗┓┗┛┏┛"
echo "︱┃┃┃┃ ┃┗━┛┃ ┗━━┓┃ ┃┏━┓┃ ┃┏━┓┃ ┃┃︱┃┃ ┃┗━┛┃ ┃┏┓┏┛ ︱┃┃┃┃ ┗━━┓┃ ︱┗┓┏┛︱"
echo "┏┛┗┛┃ ┃┏━┓┃ ┃┗━┛┃ ┃┃︱┃┃ ┃┗━┛┃ ┃┗━┛┃ ┃┏━┓┃ ┃┃┃┗┓ ┏┛┗┛┃ ┃┗━┛┃ ︱︱┃┃︱︱"
echo "┗━━━┛ ┗┛︱┗┛ ┗━━━┛ ┗┛︱┗┛ ┗━━━┛ ┗━━━┛ ┗┛︱┗┛ ┗┛┗━┛ ┗━━━┛ ┗━━━┛ ︱︱┗┛︱︱"
echo ""
echo ""

echo "This script must be executed with root privileges (sudo)."
echo ""

read -p "Enter the password for mariadb database [Note: Skipping this step may corrupt the installation]: " databasepassword
echo ""
read -p "Enter the url where Dashboardsy Should be installed [Note: Don't use http:// or https:// and domain should point to ip of this server]: " dashurl
echo ""
read -p "Enter the secret cookie password [32 chars min]: " cookiepassword
echo ""
read -p "Enter the Discord OAuth Client ID [https://discord.dev > Applicaton > OAuth2 > General > Client ID]: " clientid
echo ""
read -p "Enter the Discord OAuth Client Secret [https://discord.dev > Applicaton > OAuth2 > General > Client Secret]: " clientsecret
echo ""
read -p "Enter the panel url [Note: Don't use http:// or https://]: " panelurl
echo ""
read -p "Enter the admin api key of panel [With all Read Write Permissions, or the dashboard may not work properly]: " panelapi
echo ""
read -p "Enter the Location Id of Server Creation: " locationid
echo ""
read -p "Enter the Location Name, will be displayed on the dashboard: " locationname
echo ""
read -p "Enter The CPU Price for Shop Per 100%: " cpuprice
echo ""
read -p "Enter The Ram Price for Shop Per 100MB: " ramprice
echo ""
read -p "Enter The DISK Price for Shop Per 100MB: " diskprice
echo ""
read -p "Enter The Server Slot Price for Shop Per 1 Slot: " slotprice


echo "------------------------------"
echo "-INSTALLING REQUIRED PACKAGES-"
echo "------------------------------"
sudo apt update
apt install git
apt install nginx

echo ""

echo "Installing Nodejs"

apt-get install curl git nginx software-properties-common
curl -sL https://deb.nodesource.com/setup_16.x | bash - 
sudo apt-get install -y nodejs

echo ""

echo "Installing Mariadb database"
echo ""

sudo apt install mariadb-server
sudo mysql_secure_installation
sudo systemctl start mariadb.service


echo "Configuring Mariadb database"

mariadb -u root --execute "CREATE DATABASE dashboardsy;"
mariadb -u root --execute "CREATE USER 'dashboardsy'@'localhost' IDENTIFIED BY '$databasepassword';"
mariadb -u root --execute "GRANT ALL PRIVILEGES ON dashboardsy.* TO 'dashboardsy'@'localhost';"
mariadb -u root --execute "FLUSH PRIVILEGES;"

echo ""

echo "Cloning Dashboardsy Repository"

git clone https://github.com/Wrible-Development/Dashboardsy
cd Dashboardsy

mv .env.example .env

echo ""
echo "-------------------"
echo "-Configuring Files-"
echo "-------------------"

echo ""
echo "Configuring .env"

echo "NEXTAUTH_URL=https://$dashurl
NEXTAUTH_URL_INTERNAL=http://localhost:3000
" > .env

echo ""
echo "Configuring next.config.js"

curl -o next.config.js https://raw.githubusercontent.com/BreadCatto/dashboardsy-installer/main/next.config.js

sed -i -e "s@dash.example.com@${dashurl}@g" next.config.js
sed -i -e "s@cookiepass@${cookiepassword}@g" next.config.js
sed -i -e "s@dbpass@${databasepassword}@g" next.config.js
sed -i -e "s@clientid@${clientid}@g" next.config.js
sed -i -e "s@clientsecret@${clientsecret}@g" next.config.js


echo ""
echo "Configuring config.json"

curl -o config.json https://raw.githubusercontent.com/BreadCatto/dashboardsy-installer/main/config.json
sed -i -e "s@panelurl@${panelurl}@g" config.json
sed -i -e "s@apikey123@${panelapi}@g" config.json
sed -i -e "s@69@${locationid}@g" config.json
sed -i -e "s@location1@${locationname}@g" config.json
sed -i -e "s@2334@${cpuprice}@g" config.json
sed -i -e "s@5363@${ramprice}@g" config.json
sed -i -e "s@2353@${diskprice}@g" config.json
sed -i -e "s@2623@${slotprice}@g" config.json

echo ""
echo "------------------------"
echo "-Configuration Complete-"
echo "------------------------"

echo ""
echo "--------------------"
echo "-Starting Dashboard-"
echo "--------------------"

npm install
npm install -g pm2
npm run build

pm2 start --name=dashboardsy npm -- start
systemctl start nginx
sudo apt install certbot
sudo apt install -y python3-certbot-nginx
certbot certonly --nginx -d $dashurl

echo ""
echo "---------------------------"
echo "-Configuring Reverse proxy-"
echo "---------------------------"

cd /etc/nginx/conf.d

touch dashboardsy.conf

curl -o /etc/nginx/conf.d/dashboardsy.conf https://raw.githubusercontent.com/BreadCatto/dashboardsy-installer/main/dashboardsy.conf 
sed -i -e "s@<domain>@${dashurl}@g" /etc/nginx/conf.d/dashboardsy.conf

systemctl restart nginx

echo ""
echo "------------------------------------------------------------------------"
echo "-Dashboardsy Normal Installation Complete, Please configure config.json-"
echo "-if you want to add more eggs, locations, or something else            -"
echo "-then run "npm build" and "pm2 restart dashboardsy"                    -"
echo "------------------------------------------------------------------------"