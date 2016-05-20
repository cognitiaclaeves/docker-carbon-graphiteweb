## Graphite + Carbon

Forked from: https://github.com/steeef/dockerfiles

An all-in-one image running graphite and carbon-cache, Running on CentOS 6.x
(installed from EPEL).

This image contains a sensible default configuration of graphite and
carbon-cache. Starting this container will, by default, bind the the following
host ports:

- `80`: the graphite web interface
- `2003`: the carbon-cache line receiver (the standard graphite protocol)
- `2004`: the carbon-cache pickle receiver
- `7002`: the carbon-cache query port (used by the web interface)

With this image, you can get up and running with graphite by simply running:

    docker run -d -P -e SECRET_KEY='random-secret-key' abezhenar/graphite-centos

If you want to allow access to SSH, you'll also need to pass '-t' for
pseudo-tty.

You can log into the administrative interface of graphite-web (a Django
application) with the username `admin` and password `admin`. These passwords can
be changed through the web interface.

**NB**: Please be aware that by default docker will make the exposed ports
accessible from anywhere if the host firewall is unconfigured.

### Data volumes

Graphite data is stored at `/var/lib/graphite/storage/whisper` within the
container. If you wish to store your metrics outside the container (highly
recommended) you can use docker's data volumes feature. For example, to store
graphite's metric database at `/data/graphite` on the host, you could use:

    docker run -v /data/graphite:/var/lib/graphite/storage/whisper \
               -d steeef/graphite-centos

### Technical details

By default, this instance of carbon-cache uses the following retention periods
resulting in whisper files of approximately 2.5MiB.

    10s:8d,1m:31d,10m:1y,1h:5y

For more information, see [the
Docker Index page](https://index.docker.io/u/steeef/graphite-centos).
