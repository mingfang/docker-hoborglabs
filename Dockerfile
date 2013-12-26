FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat

#Dashboard Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 php5-common libapache2-mod-php5 php5-cli

RUN curl -s http://get.hoborglabs.com/dashboard/install | php && \
    rm -rf /var/www && \
    ln -s /htdocs /var/www

#Configuration
ADD . /docker-dashboard
RUN cd /docker-dashboard && \
    cp supervisord-dashboard.conf /etc/supervisor/conf.d

EXPOSE 22 80
