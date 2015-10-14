#!/usr/bin/env bash
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distrbuted under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

generate-classpath() {
  if [ ! -f /tmp/cp.txt ]
  then
    echo "Generating classpath..."
    mvn dependency:build-classpath -Dmdep.outputFile=/tmp/cp.txt

    echo "Generated classpath:"
    cat /tmp/cp.txt
  fi
}

setup-security-config() {
  mkdir -p /var/lib/ambari-server/keys
  cp -r /ambari/ambari-server/src/main/resources/db /var/lib/ambari-server/keys/db
  cp /ambari/ambari-server/conf/unix/ca.config /var/lib/ambari-server/keys/
}

create-version-file() {
  echo "Set ambari-server version to $SERVER_VERSION"
  echo $SERVER_VERSION > /ambari-server-conf/version
}

upgrade-schema() {
  export CONTAINER_IP=$(hostname -i)
  echo "Container IP address": $CONTAINER_IP

  echo "Starting the application .."
  java \
    -Dfile.encoding=UTF-8 \
    -Dlog4j.configuration=file:/ambari-server-conf/log4j.properties \
    -Xmx2048m -Xms256m \
    -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=50100 \
    -classpath $(cat /tmp/cp.txt):target/classes:/ambari-server-conf:/ambari/ambari-views/target \
    org.apache.ambari.server.upgrade.SchemaUpgradeHelper
}

set-path() {
  export PATH=$PATH:/ambari/ambari-common/src/main/unix
}

main() {
  cd /ambari/ambari-server
  generate-classpath
  set-path
  setup-security-config
  create-version-file
  upgrade-schema
}

main "$@"
