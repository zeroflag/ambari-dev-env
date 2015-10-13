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

main() {
  yum install -y /ambari/ambari-agent/target/rpm/ambari-agent/RPMS/x86_64/ambari-agent-*.x86_64.rpm
  ambari-agent reset ambari-server
  ambari-agent start -v
  /etc/init.d/sshd start
  while true; do
    sleep 3
    tail -f /var/log/ambari-agent/ambari-agent.log
  done
}

main "$@"