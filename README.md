# README

Entorno local para desarrollo de aplicaciones en Python

La versión de Python se gestiona con Pyenv, y se crean entornos virtuales para gestionar las dependencias del proyecto.

# Cómo usar este repositorio

* Asegúrese de instalar los requisitos

* clone el repo:

```bash
git clone https://github.com/CesarBallardini/localenv-python
```

Configure si desea otros valores diferentes a los provistos.  Puede dejar todo sin modificar y el sistema será completamente funcional.

## Gestionar el ciclo de vida de la VM

* levante la VM:

```bash
cd localenv-python/
cp Vagrantfile.virtualbox Vagrantfile ; time vagrant up  # usa Virtualbox como provider

# o bien
cp Vagrantfile.docker Vagrantfile ;  time vagrant up  # usa Docker como provider, ej. en una Apple MAC con procesador M1

```

El `vagrant up` va a crear una VM con Ubuntu 20.04 llamada `pydev` con dirección IP 192.168.56.10 en la red _host only_ de Virtualbox, lo cual permite accederla 
desde la pc o notebook que aloja el Virtualbox.

Como siempre en el caso de Vagrant, se puede ingresar mediante SSH con el mandato:

```bash
vagrant ssh
```

Para detener la VM:

```bash
vagrant halt
```

y para destruirla por completo:

```bash
vagrant destroy -f
```



# Requisitos

* Vagrant (verificado con 2.2.18)

* Plugins para Vagrant:

  * vagrant-cachier (1.2.1) (caché de paquetes DEB, etc.)
  * vagrant-hostmanager (1.8.9) (para modificar automáticamente el `/etc/hosts` en VM y _host_)
  * vagrant-proxyconf (2.0.10) (si debe salir a internet a través de un _proxy_ corporativo)
  * vagrant-reload (0.0.1)
  * vagrant-vbguest (0.30.0)

* Virtualbox (verificado con 6.1.28r147628) o Docker (verificado con version 19.03.12, build 48a66213fe) como provider.

* Git (verificado con 2.25.1)



# Referencias

* https://github.com/pyenv/pyenv Simple Python Version Management: pyenv
* https://github.com/pyenv/pyenv-installer pyenv installer

