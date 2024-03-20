#!/usr/bin/bash

set -e 

echo "Starting postgresql server..."
sudo service postgresql start

# should only run once, the first time container is run
if [ ! -f /tmp/first_time ]; then
    echo "Creating new user for postgres..."
    cd /tmp
    sudo -u postgres psql -c "CREATE USER cmsuser WITH PASSWORD '$DBPASSWORD';"
    sudo -u postgres createdb --username=postgres --owner=cmsuser cmsdb
    sudo -u postgres psql --username=postgres --dbname=cmsdb --command='ALTER SCHEMA public OWNER TO cmsuser'


    echo "Setting up password..."
    sudo sed 's/your_password_here/'"$DBPASSWORD"'/g' /usr/local/etc/cms.conf > /tmp/cms.conf.tmp && sudo mv /tmp/cms.conf.tmp /usr/local/etc/cms.conf
    
    NEW_SECRET=`cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1`
    sudo sed 's/8e045a51e4b102ea803c06f92841a1fb/'"$NEW_SECRET"'/g' /usr/local/etc/cms.conf > /tmp/cms.conf.tmp && sudo mv /tmp/cms.conf.tmp /usr/local/etc/cms.conf
    cmsInitDB

    # set flag to prevent re-runs
    touch /tmp/first_time
fi

echo "Starting services in background..."
cmsLogService &
cmsRankingWebServer &

echo "Running in background..."
tail -f /dev/null