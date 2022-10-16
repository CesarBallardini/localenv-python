# README - Local environment to develop Python applications

Python version is managed with Pyenv, and a virtual environment is created to manage project dependencies

# How to use this repository

* Make sure that the requirements are installed.

* make a clone of repo:

```bash
git clone https://github.com/CesarBallardini/localenv-python
```

You can customize the values if you like.  If you let the default values, it will be OK.

## Manage the VM's lifecycle

* launch the VM:

```bash
cd localenv-python/
cp Vagrantfile.virtualbox Vagrantfile ; time vagrant up  # uses Virtualbox as provider

# or, if you want to use Docker instead of Virtualbox, (ie. on Apple MAC with M1 processor), you choose the synced folder type:
cp Vagrantfile.docker.volume Vagrantfile ;  time vagrant up  # uses Docker volume as synced folder, recomended

```

The `vagrant up` command creates an Ubuntu 22.04 node called `pydev`.
The network is _host only_, so you can access it from the host (PC or laptop).

You can access with SSH:

```bash
vagrant ssh
```

You can stop the VM:

```bash
vagrant halt
```

And you can destroy it:

```bash
vagrant destroy -f
```

## Use the local Python environment

The provisioning creates a directory to hold an example project: `my-sample-project`.  In the `Vagrantfile`
you have the following variables in case you want to customize some aspects of the environment:


* `PROJECT_DIR="/vagrant/my-sample-project"`
* `MY_PYTHON_VERSION="3.10.2"`


So you can change to the project directory:

```bash
cd /vagrant/my-sample-project/
```

Activate the virtual environment:

```bash
source venv/bin/activate
```

and then you can run tests, code linting and formatting, etc.

Just to see some of this tools in action, you can run:

```bash
/vagrant/provision/5-run-style-tools.sh
```
## Using vscode inside the Docker container

You will need `socat` program installed on the host, if you want to use X GUI programs
running on the Docker container and displayed on the host screen.
You won't need socat with the Virtualbox VM version.

The container need access to the socket where X server accepts connections.

With old/traditional filesystem sockets in the host, the commands that run at container launching time
(`vagrant up`) will be enough to get GUI programs inside the container displayed on the X server in the host.

In modern systems the sockets are [_abstract unix sockets_](https://manpages.debian.org/bullseye/manpages/unix.7.en.html#Abstract_sockets). You
need to proxy between the abstract socket and the traditional socket, so the container can access the traditional one.

We can use `socat` to do the proxy thing, so you need to install it on your host machine.  The `socat` was already provisioned on the container.

When you need to run GUI programs inside the container (i.e. vscode) you need to open another terminal in the host and run:

```bash
socat unix-listen:/tmp/.X11-unix/X0,umask=000,fork abstract-connect:/tmp/.X11-unix/X0
```

Where `/tmp/.X11-unix` is the value of `XSOCK` variable in `Vagrantile`

* Reference: https://unix.stackexchange.com/questions/716838/find-my-display-socket

# Requirements

* Vagrant (checked with 2.2.18)

* Vagrant plugins:

  * vagrant-cachier (1.2.1) (DEB package cachè, etc.)
  * vagrant-hostmanager (1.8.9) (automatically modifies `/etc/hosts` in VM and  _host_)
  * vagrant-proxyconf (2.0.10) (if you are connected to the Internet via corporate _proxy_)
  * vagrant-reload (0.0.1)
  * vagrant-vbguest (0.30.0)

* Virtualbox (checked with version 6.1.28r147628) o Docker (checked with version 19.03.12, build 48a66213fe) as provider.

* Git (checked with version 2.25.1)


# References

* https://github.com/pyenv/pyenv Simple Python Version Management: pyenv
* https://github.com/pyenv/pyenv-installer pyenv installer

