#!/usr/bin/env bash
set -ev

taskd init

# this will segfault if these are unset... so this is required
taskd config --force ca.cert /tasks/ssl/ca.cert.pem
taskd config --force server.crl /tasks/ssl/server.crl.pem
taskd config --force server.key /tasks/ssl/server.key.pem
taskd config --force server.cert /tasks/ssl/server.cert.pem
taskd config --force client.key /tasks/ssl/client.key.pem
taskd config --force client.cert /tasks/ssl/client.cert.pem

for ORG in $(ls /tasks/init-orgs/); do
  if [ -d "/tasks/init-orgs/$ORG" ] && [ ! -d "/tasks/orgs/$ORG" ]; then
    taskd add org "$ORG"
  fi
  for USER in $(ls "/tasks/init-orgs/$ORG/"); do
    exists=false
    for EXISTING in $(ls "/tasks/orgs/$ORG/users/"); do
      if [[ "x$(grep "user=${USER}" /tasks/orgs/${ORG}/users/${EXISTING}/config)" != "x" ]]; then
        exists=true
        break
      fi
    done
    if ! $exists; then
      taskd add user "$ORG" "$USER"
    fi
  done
done

taskd config --force log /dev/stderr
taskd config --force pid.file /tmp/taskd.pid
taskd config --force server "${TASKD_HOSTNAME-localhost}:${TASKD_PORT-7358}"

# log a few things
taskd config
ls -R /tasks
id

taskd server --data /tasks
