FROM fedora
RUN curl -o /etc/yum.repos.d/bintray-reznikmm-matreshka.repo \
 https://bintray.com/reznikmm/matreshka/rpm && \
 dnf --assumeyes install gcc-gnat && \
 dnf --assumeyes install gprbuild && \
 dnf --assumeyes install make && \
 dnf --assumeyes install gdb && \
 dnf --assumeyes install --repo bintray--reznikmm-matreshka matreshka-devel && \
useradd max
COPY ada-lsp.tar.gz /src/

