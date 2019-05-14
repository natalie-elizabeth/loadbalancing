#!/bin/bash
PROJECT_ID=tech_infra
MYSQL_PASSWORD=$(curl "http://metadata.google.internal/computeMetadata/v1/project/attributes/mysql_password" -H "Metadata-Flavor: Google")
SLAVE_PASSWORD=$(curl "http://metadata.google.internal/computeMetadata/v1/project/attributes/slave_password" -H "Metadata-Flavor: Google")
SLAVE_UNAME=$(curl "http://metadata.google.internal/computeMetadata/v1/project/attributes/slave_name" -H "Metadata-Flavor: Google")
DEBIAN_FRONTEND="noninteractive"

HAPROXY_SQL_PASSWORD=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/haproxy_sql_password -H "Metadata-Flavor: Google")

