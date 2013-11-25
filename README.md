# docker-php5-stack

A Dockerfile which produces a docker image that runs a full [PHP5][php] stack with [Nginx][nginx], [MariaDB][mariadb], and [Postfix][postfix].

[php]: http://us.php.net/
[nginx]: http://wiki.nginx.org/
[mariadb]: https://mariadb.org/
[postfix]: http://www.postfix.org/

## Image Creation

```
$ sudo docker build -t="paintedfox/php5-stack" .
```

## Container Creation / Running

The Nginx server is configured to host a website from the `/srv/www` folder inside the container.  The MariaDB server is configured to use the `/data` folder inside the container.  You can map the container's `/srv/www` and `/data` volumes to volumes on the host so the data becomes independant of the running container.

This example uses `/tmp/www` and `/tmp/data` to host from, but you can modify this to your needs.  In addition, the example will name the resulting container *phpwebapp* and will run this as a daemon in the background with the `-d` option.  Once the container is running, you will be able to connect to your PHP5 application through browser at `http://127.0.0.1:8080/`.

```
$ mkdir -p /tmp/www
$ mkdir -p /tmp/data
$ sudo docker run -name="phpwebapp" -p 8080:80 -v /tmp/www:/srv/www -v /tmp/data:/data -d paintedfox/php5-stack
```
