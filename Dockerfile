FROM rockylinux/rockylinux:10 AS installer

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.jlu.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/[Rr]ocky*.repo &&\
    dnf makecache &&\
    dnf install -y epel-release &&\
    sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=|baseurl=|g' \
    -e 's|//download\.fedoraproject\.org/pub|//mirrors.tuna.tsinghua.edu.cn|g' \
    -e 's|//download\.example/pub|//mirrors.tuna.tsinghua.edu.cn|g' \
    -e 's|http://mirrors|https://mirrors|g' \
    -i /etc/yum.repos.d/epel*.repo &&\
    dnf makecache
    

RUN  mkdir /tmp/thinkboxsetup/
COPY DeadlineClient-10.*-linux-x64-installer.run /tmp/thinkboxsetup/

RUN dnf install -y bzip2 libX11 libXext mesa-libGL supervisor
RUN chmod +x /tmp/thinkboxsetup/DeadlineClient-10.*-linux-x64-installer.run && \
    /tmp/thinkboxsetup/DeadlineClient-10.*-linux-x64-installer.run \
    --mode unattended \
    --unattendedmodeui minimal \
    --repositorydir /mnt/DeadlineRepository10 \
    --noguimode true \
    --enable-components proxyconfig \
    --enable-components webservice_config \
    --webservice_enabletls false\
    --restartstalled true


FROM rockylinux/rockylinux:10-minimal

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.jlu.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/[Rr]ocky*.repo &&\
    microdnf makecache

RUN microdnf install -y epel-release &&\
    sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=|baseurl=|g' \
    -e 's|//download\.fedoraproject\.org/pub|//mirrors.tuna.tsinghua.edu.cn|g' \
    -e 's|//download\.example/pub|//mirrors.tuna.tsinghua.edu.cn|g' \
    -e 's|http://mirrors|https://mirrors|g' \
    -i /etc/yum.repos.d/epel*.repo &&\
    microdnf makecache

RUN microdnf install -y file supervisor

COPY --from=installer /opt/Thinkbox /opt/Thinkbox
COPY --from=installer /var/lib/Thinkbox /var/lib/Thinkbox
COPY supervisord.conf /opt/

ENV PATH=$PATH:/opt/Thinkbox/Deadline10/bin

EXPOSE 8080 8081
