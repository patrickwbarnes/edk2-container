FROM centos:8

RUN yum -y install epel-release \
 && yum -y --enablerepo=PowerTools install \
  acpica-tools \
  gcc \
  gcc-c++ \
  git \
  libuuid-devel \
  make \
  nasm \
  python36 \
 && yum clean all \
 && alternatives --set python /usr/bin/python3

RUN curl --fail https://packages.microsoft.com/config/rhel/7/prod.repo \
  > /etc/yum.repos.d/microsoft.repo \
 && yum install -y powershell \
 && yum clean all

WORKDIR /src

RUN git clone --depth=1 https://github.com/tianocore/edk2

ENV WORKSPACE=/src/edk2

WORKDIR /src/edk2

RUN git submodule update --init
RUN make -C BaseTools
RUN . ./edksetup.sh \
 && sed -i -r \
  -e 's/^(TOOL_CHAIN_TAG\s+=\s+).*$/\1GCC5/g' \
  -e 's/^(TARGET_ARCH\s+=\s+).*$/\1X64/g' \
  -e 's/^(ACTIVE_PLATFORM\s+=\s+).*$/\1MdeModulePkg\/MdeModulePkg.dsc/g' \
  Conf/target.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

