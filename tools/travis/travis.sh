function linux_before_install()
{
    cp -r tools/travis /tmp/
    cd ..
    tar --exclude=.git \
        -c -z -f /tmp/travis/ada-lsp.tar.gz ada-lsp
    docker build --tag ada-lsp /tmp/travis/
}

function linux_script()
{
    docker run -i -t --user=max ada-lsp /bin/bash -c \
           'tar xzvf /src/ada-lsp.tar.gz -C ~ && make -C ~/ada-lsp '

}

${TRAVIS_OS_NAME}_$1
