#!/bin/bash
#export BAREOS_JOB_NAME_03="name:aslan|storage:docker-sd|schedule:standard|pool:Pool"
#export BAREOS_CLIENT_NAME_03="name:aslan|password:ParolFDEbat|address:bareos-fd|port:1488"
#export BAREOS_STORAGE_NAME_03="name:aslan|password:ParolFDEbat|address:bareos-sd|port:1488|pool:Pool"
#export BAREOS_FILESET_NAME_03="name:aslan|path:/lol/kek/cheburek"
#export BAREOS_SCHEDULE_NAME_03="name:aslan"
#export BAREOS_POOL_NAME_03="pool:Pool"
#export BAREOS_CATALOG_NAME_03="dbpassword:TyPidor"
#export BAREOS_DIRECTOR_NAME_03="password:LalkaZatralel"
#export BAREOS_WEBUI_03="username:admin|password:LalkaZatralel"

ARRAY_JOB=($(printenv | grep BAREOS_JOB | sed 's/.*=//'))
ARRAY_STORAGE=($(printenv | grep BAREOS_STORAGE | sed 's/.*=//'))
ARRAY_CLIENT=($(printenv | grep BAREOS_CLIENT | sed 's/.*=//'))
ARRAY_FILESET=($(printenv | grep BAREOS_FILESET | sed 's/.*=//'))
ARRAY_SCHEDULE=($(printenv | grep BAREOS_SCHEDULE | sed 's/.*=//'))
ARRAY_POOL=($(printenv | grep BAREOS_POOL | sed 's/.*=//'))
ARRAY_CATALOG=($(printenv | grep BAREOS_CATALOG | sed 's/.*=//'))
ARRAY_DIRECTOR=($(printenv | grep BAREOS_DIRECTOR | sed 's/.*=//'))
ARRAY_ADM_WEBUI=($(printenv | grep ADM_BAREOS_WEBUI | sed 's/.*=//'))

#/etc/bareos/bareos-dir.d/job/$job_name.conf
# config for jobs

for i in "${ARRAY_JOB[@]}"
do
jobname=`echo $i | sed 's/^.*jobname://' | sed 's/|.*$//'`
client=`echo $i | sed 's/^.*client://' | sed 's/|.*$//'`
storage=`echo $i | sed 's/^.*storage://' | sed 's/|.*$//'`
schedule=`echo $i | sed 's/^.*schedule://' | sed 's/|.*$//'`
pool=`echo $i | sed 's/^.*pool://' | sed 's/|.*$//'`
fileset=`echo $i | sed 's/^.*fileset://' | sed 's/|.*$//'`
pg_basename=`echo $i | sed 's/^.*pg_basename://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/job/$jobname.conf
Job {
  Name = "$jobname"
  Type = Backup
  Level = Full
  Client = $client
  FileSet = "$fileset"
  Storage = $storage
  Messages = Standard
  Pool = $pool
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bareos/$client.bsr"
  Schedule = "$schedule"
  RunScript {
    FailJobOnError = No
    RunsOnClient = Yes
    RunsWhen = Before
    Command = "/bin/bash /etc/bareos/bareos-fd.d/${pg_basename}_before.sh"
  }
  RunScript {
    RunsOnSuccess = Yes
    FailJobOnError = No
    RunsOnClient = Yes
    RunsWhen = After
    Command = "/bin/bash /etc/bareos/bareos-fd.d/${pg_basename}_after.sh"
  }
}
EOF
done

#/etc/bareos/bareos-dir.d/storage/$storage_name.conf


for i in "${ARRAY_STORAGE[@]}"
do
name=`echo $i | sed 's/^.*name://' | sed 's/|.*$//'`
password=`echo $i | sed 's/^.*password://' | sed 's/|.*$//'`
address=`echo $i | sed 's/^.*address://' | sed 's/|.*$//'`
port=`echo $i | sed 's/^.*port://' | sed 's/|.*$//'`
pool=`echo $i | sed 's/^.*pool://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/storage/$name.conf
Storage {
  Name = $name
  Address = $address
  Port = $port
  Password = "$password"
  Device = $pool
  Media Type = File
}
EOF
done

# config for fileset
#/etc/bareos/bareos-dir.d/fileset/$BAREOS_CLIENT_NAME.conf
for i in "${ARRAY_FILESET[@]}"
do
fileset=`echo $i | sed 's/^.*fileset://' | sed 's/|.*$//'`
path=`echo $i | sed 's/^.*path://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/fileset/$fileset.conf
FileSet {
  Name = "$fileset"
  Include {
    Options {
      Signature = MD5
      compression=GZIP
    }
    File = $path
  }
}
EOF
done

# schedule
#/etc/bareos/bareos-dir.d/schedule/$BAREOS_CLIENT_NAME.conf
for i in "${ARRAY_SCHEDULE[@]}"
do
name=`echo $i | sed 's/^.*name://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/schedule/$name.conf
Schedule {
  Name = "$name"
  Run = Full mon-sun at 01:00
}
EOF
done

# client conf
#/etc/bareos/bareos-dir.d/client/$BAREOS_CLIENT_NAME.conf

for i in "${ARRAY_CLIENT[@]}"
do
name=`echo $i | sed 's/^.*name://' | sed 's/|.*$//'`
password=`echo $i | sed 's/^.*password://' | sed 's/|.*$//'`
address=`echo $i | sed 's/^.*address://' | sed 's/|.*$//'`
port=`echo $i | sed 's/^.*port://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/client/$name.conf
Client {
  Name = $name
  Address = $address
  Port = $port
  Password = "$password"
}
EOF
done

# Pool conf
# /etc/bareos/bareos-dir.d/pool/$pool_name.conf

for i in "${ARRAY_POOL[@]}"
do
pool=`echo $i | sed 's/^.*pool://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/pool/$pool.conf
Pool {
  Name = $pool
  Pool Type = Backup
}
EOF
done

# database catalog conf
#/etc/bareos/bareos-dir.d/catalog/MyCatalog.conf

for i in "${ARRAY_CATALOG[@]}"
do
dbport=`echo $i | sed 's/^.*dbport://' | sed 's/|.*$//'`
dbaddress=`echo $i | sed 's/^.*dbaddress://' | sed 's/|.*$//'`
dbpassword=`echo $i | sed 's/^.*dbpassword://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
catalog {
  Name = MyCatalog
  dbuser = bareos
  dbname = bareos
  dbdriver = postgresql
  dbpassword = $dbpassword
  dbaddress = $dbaddress
  dbport = $dbport
}
EOF
done

#  director conf
# /etc/bareos/bareos-dir.d/director/bareos-dir.conf

for i in "${ARRAY_DIRECTOR[@]}"
do
password=`echo $i | sed 's/^.*password://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/director/bareos-dir.conf
Director {
  Name = bareos-dir
  QueryFile = "/usr/lib/bareos/scripts/query.sql"
  Maximum Concurrent Jobs = 10
  Password = "$password"
  Messages = Daemon
  Auditing = yes
}
EOF
done

#/etc/bareos/bareos-dir.d/console/admin.conf

for i in "${ARRAY_ADM_WEBUI[@]}"
do
username=`echo $i | sed 's/^.*username://' | sed 's/|.*$//'`
password=`echo $i | sed 's/^.*password://' | sed 's/|.*$//'`
cat <<EOF > /etc/bareos/bareos-dir.d/console/admin.conf
Console {
Name = "$username"
Password = "$password"
Profile = "webui-admin"
}
EOF
done

#/etc/bareos/bareos-dir.d/profile/webui-admin.conf - no changes

cat <<EOF > /etc/bareos/bareos-dir.d/profile/webui-admin.conf
Profile {
  Name = "webui-admin"
  CommandACL = !.bvfs_clear_cache, !.exit, !.sql, !configure, !create, !delete, !purge, !prune, !sqlquery, !umount, !unmount, *all*
  Job ACL = *all*
  Schedule ACL = *all*
  Catalog ACL = *all*
  Pool ACL = *all*
  Storage ACL = *all*
  Client ACL = *all*
  FileSet ACL = *all*
  Where ACL = *all*
}
EOF

# looks good

exec "$@"
