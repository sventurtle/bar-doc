# BareOS director Dockerfile
FROM       debian:stretch
MAINTAINER timofeev@lecta.ru

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN apt-get update && apt-get install -y curl gnupg2

RUN curl -Ls http://download.bareos.org/bareos/release/17.2/Debian_9.0/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/breos-keyring.gpg add - && \
    echo 'deb http://download.bareos.org/bareos/release/17.2/Debian_9.0 /' > /etc/apt/sources.list.d/bareos.list && \
    echo 'bareos-database-common bareos-database-common/dbconfig-install boolean false' | debconf-set-selections && \
    echo 'bareos-database-common bareos-database-common/install-error select ignore' | debconf-set-selections && \
    echo 'bareos-database-common bareos-database-common/database-type select psql' | debconf-set-selections && \
    echo 'bareos-database-common bareos-database-common/missing-db-package-error select ignore' | debconf-set-selections && \
    echo 'postfix postfix/main_mailer_type select No configuration' | debconf-set-selections && \
    apt-get update -qq && \
    apt-get install -qq -y bareos-director bareos-database-postgresql bareos-common bareos-bconsole

COPY confgen.sh /
RUN chmod u+x /confgen.sh

EXPOSE 9101

VOLUME /etc/bareos

ENTRYPOINT ["/bin/bash", "/confgen.sh"]
CMD ["/usr/sbin/bareos-dir", "-f"]
