#!/bin/bash
set -xe
#Building bahmni core which has embedded Tomcat Server
cd bahmni-package && ./gradlew -PbahmniRelease=${rpm_version} :core:clean :core:build
cp core/build/libs/core-1.0-SNAPSHOT.jar bahmni-lab/docker/bahmni-core.jar
cd ..
#Fetching Database Backup Data
gunzip -f -k emr-functional-tests/dbdump/openelis_backup.sql.gz
cp emr-functional-tests/dbdump/openelis_backup.sql bahmni-package/bahmni-lab/resources/openelis_demo_dump.sql
cd bahmni-package/bahmni-lab
#Extracting Migrations Zip
if [ ! -d build/migrations ]
then
mkdir -p build/migrations
fi
unzip -u -d build/migrations resources/OpenElis.zip
#Building Docker images
docker build -t bahmni/openelis-db:fresh-${OPENELIS_IMAGE_VERSION} -f docker/db.Dockerfile . --no-cache
docker build -t bahmni/openelis-db:demo-${OPENELIS_IMAGE_VERSION} -f docker/demodb.Dockerfile . --no-cache
docker build -t bahmni/openelis:${OPENELIS_IMAGE_VERSION} -f docker/Dockerfile . --no-cache
