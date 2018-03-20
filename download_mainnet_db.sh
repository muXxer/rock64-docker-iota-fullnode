#!/bin/sh

echo "Create database folder (if it doesn't exist already)..."
mkdir -p volumes/iri/mainnetdb/

echo "Delete old database..."
rm -rf volumes/iri/mainnetdb/*

echo "Download latest database..."
curl http://db.iota.partners/IOTA.partners-mainnetdb.tar.gz -o mainnetdb.tar.gz

echo "Unzip database..."
tar xzfv mainnetdb.tar.gz -C volumes/iri/mainnetdb/

echo "Remove downloaded database file..."
rm mainnetdb.tar.gz

echo "...finished!"
