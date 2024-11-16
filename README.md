# idle-sleep: Automatically power off idle servers to save energy

Large servers can consume as much as `400 W` in idle state, i.e., when they do not run any useful workload. If such a server is idling, say, 30% of the time, it will waste `~1000 kWh` per year.
This is enough electricity to run an energy-efficient single household with a fridge, TV, dishwasher, washing machine, lights, laptop etc. etc.!

Using the instructions below, you can configure your servers to turn off automatically once idle state is detected, and bring it back online remotely (via IPMI) once needed.
This setup has been successfully used on our lab servers since March 2023, leading to estimated `~20%` energy saving. 

## Configuration

### 1. Add your servers to the `hostfile`. 
Format: `server_name ipmi_ip_address`

### 2. Configure IPMI users and passwords:
Check existing IPMI users:
```
sudo ipmitool user list 1
```
Find an empty user slot. We will use slot `14` and password `IPMIpwdSLEEP` in the example below: 
```
echo "IPMIpwdSLEEP" > ./ipmipwd.txt

sudo ipmitool user set name 14 ecosleep

sudo ipmitool user set password 14 "IPMIpwdSLEEP"

sudo ipmitool user enable 14

sudo ipmitool channel setaccess 1 14 callin=on ipmi=on link=on privilege=3

sudo ipmitool lan set 1 access on
```

### 3. Install scripts
Default location: `/opt/idle-sleep`. If you want to install elsewhere, please edit `crontab`, `sudoers.d/ecosleep` and `profile.d/ecosleep.sh` files accordingly. 

```
sudo mkdir -p /opt/idle-sleep

sudo cp * /opt/idle-sleep
```


### 4. Add cron job:

```
sudo crontab ./crontab
```

### 5. Configure aliases and permissions:
By default, members of the `ecosleep` group will be allowed to manually shutdown the server by running the `ecosleep` command.
If you do not want this, just skip the following steps.
If you want to use a different (existing) group, please edit `sudoers.d/ecosleep` file accordingly.

```
sudo addgroup ecosleep

sudo cp profile.d/* /etc/profile.d/

sudo cp sudoers.d/* /etc/sudoers.d/
```

## Usage

* Show server status

```
$ srvlist.sh 
tom         ON
jerry       OFF
fry         OFF
amy         ON
```

* Temporary disable automatic shutdown:

```
tom$ ecosleep.sh disable 24h
Server will not be powered off until: Sat Jan 13 20:02:29 CET 2024
```

* Enable/status check:

```
tom$ ecosleep.sh enable
tom$ ecosleep.sh status
EcoSleep enabled
```

* Wake up server remotely:

```
$ wakeup.sh tom
Chassis Power Control: Up/On
waiting for tom ................................................................................................
Server is back online!
```
