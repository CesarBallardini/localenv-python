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

# or, if you want to use Docker instead of Virtualbox
cp Vagrantfile.docker Vagrantfile ;  time vagrant up  # uses Docker as provider, ie. on Apple MAC with M1 processor

```

The `vagrant up` command creates an Ubuntu 22.04 node called `pydev`.  The network is _host only_, so you can access it from the host (PC or laptop).

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

