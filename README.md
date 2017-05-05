Update and Install

```
$ sudo apt-get update
$ sudo apt-get install git npm librrds-perl
$ git clone https://github.com/Crahl/nodejs_p2pool_scanner.git
$ cd nodejs_p2pool_scanner
$ npm install
```
Install perl modules
```
$ sudo cpan JSON
$ sudo cpan POE::Component::Client::HTTP
$ sudo cpan Geo::IP

$ cd /tmp
$ wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
$ gunzip GeoLiteCity.dat.gz
$ sudo mkdir /usr/local/share/GeoIP
$ sudo mv GeoLiteCity.dat /usr/local/share/GeoIP/
```
Start Server

$ nodejs server.js
```
View base page at localhost:3000/
View map page at localhost:3000/map
View chart page at localhost:3000/chart
```


To find new P2Pool servers, a local P2Pool server needs to be running and the 'addrs' file exposed to the 'perl/p2pool_scanner.pl' file.

In my setup I used the nodejs 'http-server' module to serve up the 'addrs' file statically on port 8080 and set that '$url' variable in the perl/p2pool_scanner.pl file.

To collect P2Pool network data for the chart page a running P2Pool sever address ($url variable) needs to be set in 'perl/getData.pl'



