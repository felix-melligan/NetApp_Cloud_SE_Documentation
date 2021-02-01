# Optional Installation

**NOTE: These instructions should only be used if you absolutely cannot deploy using any of the other methods listed (via cloudmanager.netapp.com or via the MarketPlace) and only after recommendation by NetApp.**

**1.)** copy files (rep.zip. scala.zip and unzip-6.0-21.el7.x86_64.rpm)

**2.)** sudo su

**3.)** rpm -ivha unzip-6.0-21.el7.x86_64.rpm

**4.)** unzip rep.zip -d /

**5.)** chmod 777 /rep/awscli-bundle/install

**6.)** /rep/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

**7.)** cp /rep/trident-installer/tridentctl /usr/bin/

**8.)** rpm -ivha /rep/rpm/*.rpm --replacepkgs

**9.)** yum remove mariadb-libs (not mandatory - ctrl + c after "Verifying  : 2:postfix-2.10.1-9.el7.x86_64")

**10.)** rpm -ivha /rep/mysql/*.rpm --replacepkgs

**11.)** systemctl stop firewalld

**12.)** systemctl disable firewalld

**13.)** vi /etc/my.cnf

#add the folowing line after this line: "socket=/var/lib/mysql/mysql.sock"

**14.)** lower_case_table_names=1

**15.)** systemctl start mysqld

**16.)** chmod 777 /rep/OnCommandCloudManager-V3.8.9.sh

**17.)** /rep/OnCommandCloudManager-V3.8.9.sh (use default settings)

#after seeing "***** Waiting For Web Server to be up *****"

**18.)** ctrl c

**19.)** systemctl stop occm

**20.)** cat /etc/.java/.systemPrefs/com/netapp/occm/prefs.xml (find password in line  <entry key="mysql.password" value="password"/>

**21.)** mysqladmin -u root password $TMP_DB_Passw

**22.)** mysql -uroot -p$TMP_DB_Passwd -e "create database oncloud"

**23.)** unzip scala.zip -d /

**24.)** systemctl start occm

**25.)** log in to http://IP/ or https://IP/ (you will get an error)

**26.)** systemctl stop occm

**27.)** vi /opt/application/netapp/cloudmanager/app.conf

{<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    "occm" : {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        "system-id" : "a4089572-3b8b-4462-b7c5-650168bcd325",<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;               "ignore-proxy-gcp" : true,<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        "ipa-service-password" : "YjAwMGMyYmFlNzkzNGNhZFKZ1HYwp226t8bKjMOodPE=\n",<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        "proxy" : {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;            "uri" : "https://192.168.27.203:84"<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        },<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    }<br>
}<br>

**28.)** systemctl start occm

**29.)** log in to http://IP/ or https://IP/
