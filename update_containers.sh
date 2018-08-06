#/bin/bash
# Automatically pull and update new container version
echo "##############################################"
echo "# rock64-iota update script                  #"
echo "##############################################"

echo "##############################################"
echo "# Pulling all rock64-iota containers updates #"
echo "##############################################"

docker-compose pull

echo "##############################################"
echo "# Stopping all rock64-iota docker containers #"
echo "##############################################"

docker-compose stop

echo "##############################################"
echo "# Removing all old rock64-iota containers    #"
echo "##############################################"
docker-compose rm -f iri
docker-compose rm -f nelson.cli
docker-compose rm -f nelson.gui
docker-compose rm -f field.cli

echo "##############################################"
echo "# Restarting all rock64-iota containers      #"
echo "##############################################"

docker-compose up -d

echo "##############################################"
echo "# Updating rock64-iota containers done!      #"
echo "##############################################"

