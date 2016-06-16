1.) put the scripts into /etc/init.d
2.) change permissions "chmod +x ews*"
3.) tell linux to start the services on boot time
  unicorn has to bestarted after the websockets
  
Webosckets:
  update-rc.d "fille-name" default
Unicron:
  update-rc.d "ews2" 40

