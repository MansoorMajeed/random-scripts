## README
This init script can be used with mosquitto. I have tested it only on Ubuntu 14.04. It should work 
on any similar distro however


### How to use?
Simply copy the `mosquitto` file to `/etc/init.d/mosquitto` 
Give execute permission `chmod +x /etc/init.d/mosquitto` and you should be able to do 

```
service mosquitto start
service mosquitto stop
service mosquitto restart
```

