# Using Docker to Manage Versions of a Programming Language
## An Introduction

If you're here, you either want to learn Docker, or find a better way to manage various programming languages and their versions.

For this use case, we explore Docker in the context of providing a "clean" way to install multiple versions of your favorite language (e.g. Python), or experiment with new languages that you don't want to commit to installing directly on your machine.

Docker has many other cool use cases, but they are beyond the scope of this tutorial.

You can find the [full code here](https://github.com/Untitled-Blog/Docker-for-Economists).

### Download Docker 
- [Download here](https://docs.docker.com/get-docker/) and follow the instructions.
- [View supported platforms here](https://docs.docker.com/engine/install/). 
- Note, if you are using Windows 10 with WSL2 enabled, be sure to follow those instructions. You still have to download the Windows 10 version of Docker Desktop - it will not work to try and install via your WSL2 terminal. 

### Create Dockerfile 

```bash
$ mkdir docker-python-example 
$ cd docker-python-example
$ touch Dockerfile
```

Open this in your favorite text editor and add:

```docker
# Dockerfile 

# image to start from
FROM python:3.9-buster 

# explicitly set working directory 
# this comes in handy later...
WORKDIR /usr/src

# copy over files from local machine to docker
COPY requirements.txt .
COPY ./.bashrc /root/.bashrc

# this base python:3.9-buster images is itself 
# built on top of a Debian based Linux image 
# so we update, upgrade, and install vim
RUN apt update && \
	apt -y upgrade && \ 
	apt install -y vim 

# install any libraries you need
RUN pip install -r requirements.txt

# open up a bash shell
CMD ["bash"]
```

Quick note: Docker is built in layers, so the reason we separate out the `RUN` command that updates the operating system and installs vim from the `RUN` command the installs Python packages is that we may in the future want to add some Python packages. This ordering ensurs that the build will only need to redo that particlar layer (i.e. step), and not the entire thing. Alternatively, if we are unsure of what pacakges we want in this Docker environment, we could list each pip install on a separate `RUN` layer (appended to the bottom, always just before the `CMD` layer). This will ensure quicker builds in the future. 

Here is a link to [best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)  for creating a `Dockerfile`, and here is a link to [Python's page on Docker Hub](https://hub.docker.com/_/python). You can find other versions of Python here, or explore other images to build upon.

### Build Dockerfile 

This step builds your Dockerfile "recipe" into a local image and gives it a "tag" or label called "python3.9". Don't forget the "."! It tells Docker where to look for the Dockerfile.

```bash
$ docker build -t python3.9 .
```

### Run Dockerfile

Once this builds, you are ready to run! 

```bash
$ docker run -it --rm -v $PWD:/usr/src python3.9 
```

Some notes on the flags:

- `-it`: effectively runs whatever `CMD` is specified in the Dockerfile in an interactive terminal (in this case, it just opens up a bash shell).[^1] For more information, see [this link](https://docs.docker.com/engine/reference/run/). The point here is that Docker was designed to run well in the background (e.g. for deploying a web application), and so you need to be explicit about wanting to interact with the container via a terminal.

- `--rm`: remove the container after you're done. You can additionally manage your docker images and containers via `docker images`, `docker rmi [ image-id ]`, `docker container ls`, `docker container rm [ container-id ]`. 
- `-v`: this final flag specifies a so-called "volume". In this case, we bind our present working directory (`$PWD`) to the working directory we specified in the container (`/usr/src`). Docker also has their own [storage volumes](https://docs.docker.com/storage/volumes/), but for the case of interactive discovery and data analytics, binding your actual filesystem to the container allows you to edit files and have them available locally when finished. If there is a better way to do this, please let me know in the comments. 

- `python3.9`: the "tag" name we gave our image.

### Add Shortcut to Run

That's a lot to type each time we want to access our new version of Python! This shortcut function allows us to call `python-docker` with an optional argument specifying the version we want (if we use this concept to build multiple versions). 

```bash 
# ~/.bashrc

...

python-docker() {
	if [ $# -eq 0 ]; then
		p="python3.9"       # default version
	else
		p="python$1"        # user supplied version
	fi

	docker run -it --rm -v $PWD:/usr/src $p;
}
```

### Run Python 

```bash 
$ source ~/.bashrc          # source our new function
$ python-docker
```
or 

```bash 
$ python-docker 3.9         # <-- manage version here
```

After doing this, you should see the following screen: 

```bash
(docker) /usr/src

$
```

Change the `PS1` variable in the file `.bashrc` to update to your favorite terminal settings. From here, you can write files and run them in Python v3.9, and, since we included `numpy` in `requirements.txt`, we have access to that as well. 

For example: 

```python
(docker) /usr/src 

$ python 
Python 3.9.0 (default, Oct  6 2020, 21:52:53) 
[GCC 8.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy as np
>>>
>>> x = np.array([1, 2, 3])
>>> y = np.array([1, 2, 3])
>>>
>>> np.dot(x, y)
14
>>>
```



### Link to Code

If you'd like to see it all together, [here is a link to the full code](https://github.com/Untitled-Blog/Docker-for-Economists).

[^1]: The `-it` flag "instructs Docker to allocate a pseudo-TTY connected to the container’s stdin". [Link to documentation](https://docs.docker.com/engine/reference/commandline/run/).
