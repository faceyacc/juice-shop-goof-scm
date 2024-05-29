FROM ubuntu:trusty-20190515

ENV APP_SECRET=mysecretpassword
ENV DB_PASSWORD=mydbpassword

RUN apt-get update && \
    apt-get install -y \
    openssl \
    wget \
    curl \
    apache2 \
    php5 \
    mysql-server \
    nodejs \
    npm \
    ruby \
    python2.7 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash vulnerableuser && echo "vulnerableuser:password123" | chpasswd && adduser vulnerableuser sudo

COPY . /app

WORKDIR /app

RUN npm install

RUN apt-get update && \
    apt-get install -y \
    vsftpd \
    openssh-server \
    proftpd-basic \
    bind9 \
    dnsutils \
    samba \
    telnet \
    rsh-client \
    rsh-server \
    && rm -rf /var/lib/apt/lists/*

RUN echo "root:rootpassword" | chpasswd
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 80 443 22 21 53 139 445 3306 6379 11211

CMD ["/bin/bash"]

RUN echo "<?php phpinfo(); ?>" > /var/www/html/index.php

CMD service apache2 start && service ssh start && bash
