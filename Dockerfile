FROM ubuntu:18.04

RUN apt-get update -y && apt-get install -y ruby ruby-dev build-essential cron sudo openssh-server git
RUN mkdir -p /var/run/sshd
RUN gem install bundler --no-document
RUN mkdir -p /app
RUN adduser --shell /bin/bash --home /home/app app && chmod 700 /home/app && mkdir -m 700 -p /home/app/.ssh && chown app:app /home/app/.ssh \
    && echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && echo "root:root" | chpasswd && echo "app:app" | chpasswd
ADD ssh/* /home/app/.ssh/
RUN chown app:app /home/app/.ssh/* && cp -a /home/app/.ssh/id_rsa.pub /home/app/.ssh/authorized_keys \
    && chmod 600 /home/app/.ssh/id_rsa /home/app/.ssh/authorized_keys

USER app
WORKDIR /home/app
COPY . /home/app/

RUN bundle install --path=vendor/bundle

EXPOSE 22

USER root
ENTRYPOINT ["bash", "/home/app/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
