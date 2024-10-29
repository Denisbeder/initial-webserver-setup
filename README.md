# Initial Ubuntu 16.04 Web Server Setup

Ansible playbook to setup web server and playbook to deploy laravel project with
zero time.

## What initial-setup.yml playbook does

- install python3 and aptitude
- upgrade all software
- create user with sudo rights
- configure sshd: disables root login and password authentication, also allows
to login only user created on previous step

## What setup.yml playbook does

- install
  - git
  - ntp
  - vim
  - tmux
  - htop
  - curl
  - unzip
- configure automatic security updates (do not reloads server, only installs updates)
- setup timezone
- configure iptables and fail2ban
- create swap file
- setup ssl certificate with letsencrypt
- install node.js, npm and yarn
- install nginx
- install php and composer
- install mysql
- creates following folders structure
  - `/var/www/domain.com`:

## Install

```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

### Inventory file

Create `inventory` file in project root. You should specify ip address of your
server in this file.

```
[web]
46.101.210.137
```

### Environment variables

Copy `vars/main.yml.example` to `vars/main.yml` and change variable values for
your needs. For security reasons you may want to encrypt this file using
ansible-vault:
```bash
ansible-vault encrypt vars/main.yml
```
And then edit this file
with
```bash
ansible-vault edit vars/main.yml
```

To see all available variables take a look at `roles/*/defaults/main.yml`. Also
visit external roles github page for additional documentation.

To generate password for your user use

```bash
sudo apt-get install -y whois
mkpasswd --method=SHA-512
```

### Nginx and php-fpm configs

- Site config for nginx place in `roles/nginx/templates/yoursite.j2`
- Php-fpm pool config place in `roles/php/templates/yoursite.conf.j2`
- Default configs are available in this
[gist](https://gist.github.com/melihovv/ff11a76ee8b4fba28ecb4b681cb91818)

### Initial setup

By default on ubuntu 16.04 there is no python 2 and aptitude. Without those
programs ansible cannot work. To fix it run:

```bash
ansible-playbook initial-setup.yml
```

Beside it this playbook also creates user and configures ssh server.

### Provision server

This playbook setup nginx, php-fpm, mysql, nodejs, etc.

```bash
ansible-playbook setup.yml
```

### To run only specific roles

```bash
ansible-playbook setup.yml --tags=user,nginx
```

### To exclude specific roles

```bash
ansible-playbook setup.yml --skip-tags=user,nginx
```

## Security

If you discover any security related issues, please email amelihovv@ya.ru instead of using the issue tracker.

## Credits

- [Alexander Melihov](https://github.com/melihovv/initial-webserver-setup)
- [All contributors](https://github.com/melihovv/initial-webserver-setup/graphs/contributors)
