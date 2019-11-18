FROM centos:7

RUN yum -y install epel-release \
 && yum -y install \
  acpica-tools \
  gcc \
  gcc-c++ \
  git \
  libuuid-devel \
  make \
  nasm \
  openssl \
  patch \
  pesign \
  unzip \
 && yum clean all

RUN curl --fail https://packages.microsoft.com/config/rhel/7/prod.repo \
  > /etc/yum.repos.d/microsoft.repo \
 && yum install -y powershell \
 && yum clean all

WORKDIR /src

RUN curl --fail --location -o UDK2014.zip https://downloads.sourceforge.net/project/edk2/UDK2014_Releases/UDK2014.SP1.P1/UDK2014.SP1.P1.Complete.MyWorkSpace.zip \
 && unzip -d UDK2014 UDK2014.zip \
 && unzip -d Workspace UDK2014/UDK2014.SP1.P1.MyWorkSpace.zip \
 && mv Workspace/MyWorkSpace edk2 \
 && cd edk2 \
 && tar xf ../UDK2014/BaseTools\(Unix\).tar \
 && rm -rf UDK2014.zip UDK2014 Workspace

RUN curl --fail --location -O https://www.openssl.org/source/openssl-0.9.8zb.tar.gz \
 && cd /src/edk2/CryptoPkg/Library/OpensslLib \
 && tar zxf /src/openssl-0.9.8zb.tar.gz \
 && cd openssl-0.9.8zb \
 && patch -p0 -i ../EDKII_openssl-0.9.8zb.patch \
 && cd .. \
 && /bin/bash ./Install.sh

ENV WORKSPACE=/src/edk2

WORKDIR /src/edk2

RUN make -C BaseTools
RUN . ./edksetup.sh \
 && sed -i -r \
  -e 's/^(TOOL_CHAIN_TAG\s+=\s+).*$/\1GCC48/g' \
  -e 's/^(TARGET_ARCH\s+=\s+).*$/\1X64/g' \
  -e 's/^(ACTIVE_PLATFORM\s+=\s+).*$/\1MdeModulePkg\/MdeModulePkg.dsc/g' \
  Conf/target.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

