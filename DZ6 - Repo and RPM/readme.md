
## Размещаем свой RPM в своем репозитории
### Сборка собственного rpm пакета и размещение его в собственном репозитории

-----
#### Сборка кастомного nginx
##### Установим необходимый софт
    sudo yum install git rpm-build rpmdevtools gcc make automake yum-utils
##### Установим необходимые для компиляции nginx devel-файлы
    sudo yum-builddep nginx # хорошая команда, заменила мне ручную установку зависимостей
##### Скачиваем rpm с исходниками nginx. Добавим репозиторий nginx (https://nginx.org/ru/linux_packages.html)

    cat <<'EOF1' | sudo tee /etc/yum.repos.d/nginx.repo
     [nginx]
     name=nginx repo
     baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
     gpgcheck=0
     enabled=1
     [nginx-source]
     name=nginx source repo
     baseurl=http://nginx.org/packages/mainline/centos/7/SRPMS/
     gpgcheck=0
     enabled=1
    EOF1

##### Скачиваем исходники nginx, создаем в папке $HOME директории для сборки и распаковываем туда nginx.src.rpm
    yumdownloader --source nginx
    rpmdev-setuptree
    rpm -ivh /home/vagrant/nginx-*

##### Для примера уберем поддержку ipv6
    sed -i '/--with-ipv6/d' ~/rpmbuild/SPECS/nginx.spec
##### Создаем rpm
    rpmbuild -bb ~/rpmbuild/SPECS/nginx.spec

rpm пакет собран.

-----
#### Установка репозитория
##### Установим необходимый софт
    sudo yum install createrepo
##### Создаем директорию для репозитория
    sudo mkdir -p /usr/share/nginx/html/repos/x86_64
##### Копируем готовые rpm в нашу папку и создаем базу данных репозитория
    sudo cp -r ~/rpmbuild/RPMS/x86_64/* /usr/share/nginx/html/repos/x86_64
    sudo createrepo /usr/share/nginx/html/repos/x86_64
##### Создаем файл repo для нашего репозитория (пока локальный)
    cat <<'EOF' | sudo tee /etc/yum.repos.d/my.repo
    [myrepo-x86_64]
    name=my repo
    baseurl=file:///usr/share/nginx/html/repos/x86_64
    enabled=1
    gpgcheck=0
    EOF
##### Пробуем установить nginx из локального репозитория
    sudo yum --disablerepo "nginx,nginx-source,AppStream" install -y -q nginx # отключим на время другие репозитории с nginx
##### Проверим из какого репозитория установился nginx
    yum info nginx

   From repo    : myrepo-x86_64

##### Запустим и проверим nginx
    sudo systemctl enable --now nginx.service
    systemctl status nginx.service
##### Поменяем файл репозитория с локального на сетевой
    sudo sed -i 's%file:///usr/share/nginx/html/repos/x86_64%http://192.168.56.156/repos/x86_64/%' /etc/yum.repos.d/my.repo
##### Проверим репозиторий командой
    yum repoinfo "my repo"

    Repo-name    : my repo
    Repo-filename: /etc/yum.repos.d/my.repo


Задание выполнено.

## Спасибо за проверку!
