# Stroom HOWTO - Processing User Setup
This HOWTO demonstrates how to set up various files and scripts that the Stroom processing user requires.

## Assumptions
- the user has reasonable RHEL/Centos System administration skills
- installation is on a fully patched minimal Centos 7.3 instance.
- the application user `stroomuser` has been created
- the user is deploying for either
 - the example two node Stroom cluster whose storage is described [here](InstallHowTo.md#storage-scenario "HOWTO Storage Scenario")
 - a simple Forwarding or Standalone Proxy
 - adding a node to an existing Stroom cluster

## Set up the Stroom processing user's environment

To automate the running of a Stroom Proxy or Application service under out Stroom processing user, `stroomuser`, there are a number of configuration files and scripts we need to deploy.

We first become the stroomuser
```bash
sudo -i -u stroomuser
```

### Environment Variable files
When either a Stroom Proxy or Application starts, it needs predefined environment variables. We set these up in the `stroomuser` home directory.
We need two files for this. The first is for the Stroom processes themselves and the second is for the Stroom systemd service we deploy. The
difference is that for the Stroom processes, we need to `export` the environment variables where as the Stroom systemd service file just needs to read them.

The JAVA_HOME and PATH variables are to support Java running the Tomcat instances.
The STROOM_TMP variable is set to a working area for the Stroom Application to use. The application accesses this environment variable internally
via the ${stroom_tmp} context variable. Note that we only need the STROOM_TMP variable for Stroom Application deployments, so one
could remove it from the files for a Forwarding or Standalone proxy deployment.

With respect to the working area, we will make use of the [Storage Scenario](InstallHowTo.md#storage-scenario "HOWTO Storage Scenario") we have defined and hence use the directory `/stroomdata/stroom-working-p_nn_` where _nn_ is the hostname node number (i.e 00 for host stroomp00, 01 for host stroomp01, etc).

So, for the first node, _00_, we run
```bash
N=00
F=~/env.sh
printf '# Environment variables for Stroom services\n' > ${F}
printf 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'export PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
printf 'export STROOM_TMP=/stroomdata/stroom-working-p%s\n' ${N} >> ${F}
chmod 640 ${F}

F=~/env_service.sh
printf '# Environment variables for Stroom services, executed out of systemd service\n' > ${F}
printf 'JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
printf 'STROOM_TMP=/stroomdata/stroom-working-p%s\n' ${N} >> ${F}
chmod 640 ${F}
```

then we can change the __N__ variable on each successive node and run the above.

Alternately, for a Stroom Forwarding or Standalone proxy, the following would be sufficient
```bash
F=~/env.sh
printf '# Environment variables for Stroom services\n' > ${F}
printf 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'export PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
chmod 640 ${F}

F=~/env_service.sh
printf '# Environment variables for Stroom services, executed out of systemd service\n' > ${F}
printf 'JAVA_HOME=/usr/lib/jvm/java-1.8.0\n' >> ${F}
printf 'PATH=${JAVA_HOME}/bin:${PATH}\n' >> ${F}
chmod 640 ${F}
```

And we integrate the environment into our bash instantiation script as well as setting up useful bash functions. This is the same for all nodes.
Note that the `T` and `Tp` aliases are always installed whether they are of use of not. IE a Standalone or Forwarding Stroom Proxy could make
no use of the `T` shell alias.

```bash
F=~/.bashrc
printf '. ~/env.sh\n\n' >> ${F}
printf '# Simple functions to support Stroom\n' >> ${F}
printf '# T - continually monitor (tail) the Stroom application log\n'  >> ${F}
printf '# Tp - continually monitor (tail) the Stroom proxy log\n'  >> ${F}
printf 'function T {\n  tail --follow=name ~/stroom-app/instance/logs/stroom.log\n}\n' >> ${F}
printf 'function Tp {\n  tail --follow=name ~/stroom-proxy/instance/logs/stroom.log\n}\n' >> ${F}
```

And test it has set up correctly

```bash
. ./.bashrc
which java
```
which should return `/usr/lib/jvm/java-1.8.0/bin/java`

### Establish Simple Start/Stop Scripts

We create some simple start/stop scripts that start, or stop, all the available Stroom services. At this point, it's just the Stroom application and proxy.
```bash
if [ ! -d ~/bin ]; then mkdir ~/bin; fi
F=~/bin/StartServices.sh
printf '#!/bin/bash\n' > ${F}
printf '# Start all Stroom services\n' >> ${F}
printf '# Set list of services\n' >> ${F}
printf 'Services="stroom-proxy stroom-app"\n' >> ${F}
printf 'for service in ${Services}; do\n' >> ${F}
printf '  if [ -f ${service}/bin/start.sh ]; then\n' >> ${F}
printf '    bash ${service}/bin/start.sh\n' >> ${F}
printf '  fi\n' >> ${F}
printf 'done\n' >> ${F}
chmod 750 ${F}

F=~/bin/StopServices.sh
printf '#!/bin/bash\n' > ${F}
printf '# Stop all Stroom services\n' >> ${F}
printf '# Set list of services\n' >> ${F}
printf 'Services="stroom-proxy stroom-app"\n' >> ${F}
printf 'for service in ${Services}; do\n' >> ${F}
printf '  if [ -f ${service}/bin/stop.sh ]; then\n' >> ${F}
printf '    bash ${service}/bin/stop.sh\n' >> ${F}
printf '  fi\n' >> ${F}
printf 'done\n' >> ${F}
chmod 750 ${F}

```

Although one can modify the above for Stroom Forwarding or Standalone Proxy deployments, there is no issue if you use the same scripts. 

## Establish and Deploy Systemd services

### Processing or Proxy node
For a standard Stroom Processing or Proxy nodes, we can use the following service script.
(Noting this is done as root)
```bash
sudo bash
F=/etc/systemd/system/stroom-services.service
printf '# Install in /etc/systemd/system\n' > ${F}
printf '# Enable via systemctl enable stroom-services.service\n\n' >> ${F}
printf '[Unit]\n' >> ${F}
printf '# Who we are\n' >> ${F}
printf 'Description=Stroom Service\n' >> ${F}
printf '# We want the network and httpd up before us\n' >> ${F}
printf 'Requires=network-online.target httpd.service\n' >> ${F}
printf 'After= httpd.service network-online.target\n\n' >> ${F}
printf '[Service]\n' >> ${F}
printf '# Source our environment file so the Stroom service start/stop scripts work\n' >> ${F}
printf 'EnvironmentFile=/home/stroomuser/env_service.sh\n' >> ${F}
printf 'Type=oneshot\n' >> ${F}
printf 'ExecStart=/bin/su --login stroomuser /home/stroomuser/bin/StartServices.sh\n' >> ${F}
printf 'ExecStop=/bin/su --login stroomuser /home/stroomuser/bin/StopServices.sh\n' >> ${F}
printf 'RemainAfterExit=yes\n\n' >> ${F}
printf '[Install]\n' >> ${F}
printf 'WantedBy=multi-user.target\n' >> ${F}
chmod 640 ${F}
```

### Single Node Scenario with local database
Should you only have a deployment where the database is on a processing node, use the following service script. The only
difference is the Stroom dependency on the database. The database dependency below is for the MariaDB database. If you had 
installed the MySQL Community database, then replace `mariadb.service` with `mysqld.service`.
(Noting this is done as root)
```bash
sudo bash
F=/etc/systemd/system/stroom-services.service
printf '# Install in /etc/systemd/system\n' > ${F}
printf '# Enable via systemctl enable stroom-services.service\n\n' >> ${F}
printf '[Unit]\n' >> ${F}
printf '# Who we are\n' >> ${F}
printf 'Description=Stroom Service\n' >> ${F}
printf '# We want the network, httpd and Database up before us\n' >> ${F}
printf 'Requires=network-online.target httpd.service mariadb.service\n' >> ${F}
printf 'After=mariadb.service httpd.service network-online.target\n\n' >> ${F}
printf '[Service]\n' >> ${F}
printf '# Source our environment file so the Stroom service start/stop scripts work\n' >> ${F}
printf 'EnvironmentFile=/home/stroomuser/env_service.sh\n' >> ${F}
printf 'Type=oneshot\n' >> ${F}
printf 'ExecStart=/bin/su --login stroomuser /home/stroomuser/bin/StartServices.sh\n' >> ${F}
printf 'ExecStop=/bin/su --login stroomuser /home/stroomuser/bin/StopServices.sh\n' >> ${F}
printf 'RemainAfterExit=yes\n\n' >> ${F}
printf '[Install]\n' >> ${F}
printf 'WantedBy=multi-user.target\n' >> ${F}
chmod 640 ${F}
```

### Enable the service
Now we enable the Stroom service, but we **DO NOT** start it as we will manually start the Stroom services as part of
the installation process.
```bash
systemctl enable stroom-services.service
```
