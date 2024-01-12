# idle-sleep: Automatically power off idle servers to save energy

## Configuration

1. Add your servers to the `hostfile`. Format: `server_name ipmi_ip_address`

2. Configure IPMI users and passwords (TODO) 

3. Add cron job: `sudo crontab -e` + paste the content of `crontab` file

4. Configure aliases and permissions (TODO)

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
tom$ ecosleep.sh enabled
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
