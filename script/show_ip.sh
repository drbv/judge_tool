#!/bin/sh
echo "Willkommen zum Elektronischen Wertungssystem 2 " > /etc/issue
echo "Das System wird bei jedem start neu initialisiert, es werden keine Daten gespeichert" >> /etc/issue
echo "" >> /etc/issue
echo "Server-IP: $(hostname -I | awk '{print $1}')" >> /etc/issue
echo "Sollte hier keine IP stehen, bitte eine Minute warten, das Fenster anklicken und ENTER drücken" >> /etc/issue
echo "Benutzer ews2, Passwort drbv2017" >> /etc/issue
echo "" >> /etc/issue
