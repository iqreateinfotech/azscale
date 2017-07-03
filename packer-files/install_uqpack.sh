###################### CONFIGURATION SECTION #########################################

version=1.0

user=vmssusrroot

# Path from where all the build scripts are running
HOME=$(pwd)

#Sym link name 

symlinkname="pepcore_stage"

# Prepare DB connection parameters
dbname="peptide_mysql_db"
dbusername="peptideqausr"
dbpassword="PepT1deDBu5rQ@P@55"
dbhost="192.161.1.6"
dbport=3306

# Name of the environment file to be used for this environment
envfile=".env.stage"
peptide_mysql_db_profile_script="peptide_mysql_profile_release.sh"
iepycore_script="peptide_iepycore_release.sh"
index_config="config.properties.com"
release_config_file="release_config.stage"
iepy_dbproperties_file="dbproperties.py.stage"
iepy_dbproperties_path="resources/shell_scripts/information_extraction/Settings"

# nlk script name and dir
# scriptname="Python_nltk_installation.sh"
# scriptpath="resources/assets/scripts/python/tokenizer"

# git repository url
core_url=git@128.199.87.138:root/pepcore.git
branch=stage

# Name of the file process machine to be copy environment and logs file  peptide_webapp_revert.sh

# scp peptide_core_revert.sh peptidecoreroot@104.214.116.102:/peptidecoresrvrdatadrive/build



peptideiepycore_server="peptidcrawlerroot@13.84.46.183"
peptidewebappserver_server="pepwebapproot@104.214.113.111"
peptidemysqlroot_profile_server="peptidemysqlroot@192.161.1.6"
iepycore_destination="/peptidewebsitecrawlerdatadisk/build/release"
webapp_destination="/home/pepwebapproot/peptidedeploydir/build/release"
peptide_mysql_db_destination="/home/peptidemysqlroot/build/release"

# directory where the application is going to be deployed and the backup PEPTIDEAPP
PEPTIDEAPP="/usr/local/peptide"
HOME="/usr/local/"
BUILD="/usr/local/build"



#################### CREATE REQUIRED FOLDERS AND SET PERMISSIONS FOR PEP CORE###########################

cd $HOME

echo "Check and Creating the required directories"

if ! [ -d "peptide" ]; then
mkdir -p "peptide"
echo "Peptide directory is created"
fi

echo "Check and Creating the required directories"

if ! [ -d "build" ]; then
mkdir -p "build"
echo "build directory is created"
fi

echo "set the permissions for the direcotries"

# echo $password | sudo -S chmod -R 777 peptide
echo $password | sudo -S chmod -R 777 build


cd $PEPTIDEAPP

echo "Check and Creating the required directories"

if ! [ -d "storage" ]; then
mkdir -p "storage"
echo "storage directory is created"
fi

cd storage

if ! [ -d "app" ]; then
mkdir -p "app"
echo "app directory is created"
fi


if ! [ -d "logs" ]; then
mkdir -p "logs"
echo "logs directory is created"
fi


if ! [ -d "framework" ]; then
mkdir -p "framework"
echo "framework directory is created"
fi

cd $PEPTIDEAPP/storage/framework


if ! [ -d "cache" ]; then
mkdir -p "cache"
echo "cache directory is created"
fi

if ! [ -d "sessions" ]; then
mkdir -p "sessions"
echo "session directory is created"
fi

if ! [ -d "views" ]; then
mkdir -p "views"
echo "views directory is created"
fi

echo "set the permissions for the direcotries"

cd $PEPTIDEAPP
echo $password | sudo -S chmod -R 777 storage
echo $password | sudo -S chmod -R 777 bootstrap

echo "deleting old log files"
sudo rm -rf $PEPTIDEAPP/storage/logs/*.*


################### INSTALL REQUIRED PACKAGES ###############################################

cd $HOME

echo "Installing required packages"


if [ $(dpkg-query -W -f='${Status}' php7.0 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  
  sudo apt-get install -y python-software-properties
  sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
  sudo apt-get update
  sudo apt-get install -y php7.0 php7.0-cli php7.0-common libapache2-mod-php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd php7.0-bz2 php7.0-mcrypt php7.0-zip php7.0-xml php7.0-mbstring php7.0-gd php7.0-cgi
  
  sleep 2
  
  echo "php7.0 been installed"
  echo "configuring apahe2"
  
  sudo php7enmod mcrypt
  sudo a2enmod rewrite
  
  sudo service apache2 restart
  
  echo "php7.0 and apache2 been installed and configured"
  
fi

echo "install python3.5 and pip3 package"

  sudo apt-get install -y python3.5
  sudo apt-get install -y python3-pip
  
echo "installed python3.5 freshly"
 

iepy_version=$(pip3 list |grep iepy )
if [ -z "$iepy_version" ]
then
  sudo apt-get install -y build-essential python3-dev liblapack-dev libatlas-dev gfortran openjdk-8-jre python3-pip
  sleep 2
  pip3 install iepy
  sleep 3
  pip3 install -U numpy
  sleep 2
  pip3 install -U nltk
  sleep 2
  pip3 install beautifulsoup4
echo "installed iepy freshly"
else
  echo "iepy already has been installed"

fi

echo "Required packages has been updated successfully"

################### UPDATE REQUIRED LARAVEL PACKAGES AND DB UPDATE IN PEP CORE #####################

cd $PEPTIDEAPP

echo "Installing required laravel packages in pep core"

# composer install

echo "Migrating the database"

# php artisan migrate

echo "Seed the database"

# php artisan db:seed

#################### CREATE REQUIRED QUEUE LISTENERS AND RESTART THE QUEUE ###################

cd $BUILD

echo 'Creating the queue configuration for supervisor'

conf_file=pepcore.conf

# Read the queues from the release config

cd $PEPTIDEAPP

source $release_config_file > /dev/null

echo  $BUILD/$conf_file

OIFS=$IFS;
IFS="|";

cat /dev/null > $BUILD/$conf_file

echo '
[supervisord]
logfile='$PEPTIDEAPP'/supervisord.log       ; supervisord log file
logfile_maxbytes=50MB                           ; maximum size of logfile before rotation
logfile_backups=10                              ; number of backed up logfiles
loglevel=error                                  ; info, debug, warn, trace
pidfile=/var/run/supervisord.pid                ; pidfile location
nodaemon=false                                 ; run supervisord as a daemon
minfds=1024                                    ; number of startup file descriptors
minprocs=200                                 ; number of process descriptors
childlogdir='$PEPTIDEAPP'                 ; where child log files will live' >> $BUILD/$conf_file

echo $queue_list_core

queues=($queue_list_core)

echo $queue

# Create the supervisor configurations and append in the conf file

for i in “${queues[@]}”

do
  
   queue_config="${i/”/}"
   queue_config="${queue_config/“/}"
      
    OIFS=$IFS;
    IFS="^";
      
    queue=($queue_config)
    
    queue_name=${queue[0]}
    no_of_process=${queue[1]}
    
    process_name='process_name='$queue_name'Listener'
    
    if [ $no_of_process != 1 ]; then
      process_name='process_name=%(program_name)s_%(process_num)02d'
    fi
    
    echo '    

[program:'$queue_name']
directory='$PEPTIDEAPP'
command=php artisan queue:work --daemon --queue='$queue_name' --tries=3 --timeout=3600
autostart=true
autorestart=true
user='$user'
numprocs='$no_of_process'
redirect_stderr=true 
'$process_name'
stdout_logfile='$PEPTIDEAPP'/storage/logs/'$queue_name'Listener.log' >> $BUILD/$conf_file
  
done 

echo '

[program:WebSocket]
directory='$PEPTIDEAPP'
command=php artisan websocket:start
autostart=true
autorestart=true
user='$user'
numprocs=1
redirect_stderr=true 
process_name=WebSocketListener
stdout_logfile='$PEPTIDEAPP'/storage/logs/WebSocketListener.log' >> $BUILD/$conf_file

# Move the configuration file to the supervior conf folder and restart the listeners.

sudo mv -f $BUILD/$conf_file /etc/supervisor/conf.d/$conf_file

sudo service supervisor stop

sleep 10

sudo service supervisor start

sleep 10

echo 'Queue listeners are configured and restarted supervior'

#################### CHECK AND UPDATE THE SYSTEM CONFIGURATIONS ###################

cd $BUILD

upload_max_filesize=256M
post_max_size=256M
memory_limit=-1
 
restart_apache='false'

# Check that upload max file is matching or not, if not set 
php_upload_max_filesize=$(php -r "echo ini_get('upload_max_filesize');")
 
if [ $upload_max_filesize != $php_upload_max_filesize ];then
  
  restart_apache='true'
  
  if [ -d "/etc/php/7.0/cli/" ]; then   
    echo 'upload_max_filesize='$upload_max_filesize | sudo tee -a /etc/php/7.0/cli/php.ini
  fi
  
  if [ -d "/etc/php/7.0/apache2" ]; then   
    echo 'upload_max_filesize='$upload_max_filesize | sudo tee -a /etc/php/7.0/apache2/php.ini
  fi
    
  if [ -d "/etc/php/7.0/cgi" ]; then   
    echo 'upload_max_filesize='$upload_max_filesize | sudo tee -a /etc/php/7.0/cgi/php.ini
  fi
  
  echo 'php.ini upload_max_filesize has been set to '$upload_max_filesize
fi

# Check that post max size file is matching or not, if not set
php_post_max_size=$(php -r "echo ini_get('post_max_size');")
 
if [ $post_max_size != $php_post_max_size ];then
  
  restart_apache='true'
  
  if [ -d "/etc/php/7.0/cli/" ]; then   
    echo 'post_max_size='$post_max_size | sudo tee -a /etc/php/7.0/cli/php.ini
  fi
  
  if [ -d "/etc/php/7.0/apache2" ]; then   
    echo 'post_max_size='$post_max_size | sudo tee -a /etc/php/7.0/apache2/php.ini
  fi
    
  if [ -d "/etc/php/7.0/cgi" ]; then   
    echo 'post_max_size='$post_max_size | sudo tee -a /etc/php/7.0/cgi/php.ini
  fi
  
  echo 'php.ini post_max_size has been set to '$post_max_size
fi

# Check that max memory size file is matching or not, if not set
php_memory_limit=$(php -r "echo ini_get('memory_limit');")
 
if [ $memory_limit != $php_memory_limit ];then
  
  restart_apache='true'
  
  if [ -d "/etc/php/7.0/cli/" ]; then   
    echo 'memory_limit='$memory_limit | sudo tee -a /etc/php/7.0/cli/php.ini
  fi
  
  if [ -d "/etc/php/7.0/apache2" ]; then   
    echo 'memory_limit='$memory_limit | sudo tee -a /etc/php/7.0/apache2/php.ini
  fi
    
  if [ -d "/etc/php/7.0/cgi" ]; then   
    echo 'memory_limit='$memory_limit | sudo tee -a /etc/php/7.0/cgi/php.ini
  fi
  
  echo 'php.ini memory_limit has been set to '$memory_limit
fi

if [ $restart_apache = 'true' ]; then

  echo "Restarting apache2 service"

  sudo service apache2 restart

  sleep 5
fi
