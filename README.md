# Shiori


## How to run
https://noted.lol/tutorial-setting-up-shiori/

If you want to use a specific data directory instead of the current working directory, you can create a directory on your host machine and mount it. For example:
```
mkdir -p ~/shiori/data
docker run -d --name shiori -p 8080:8080 -v ~/shiori/data:/shiori ghcr.io/go-shiori/shiori
```
replace ghcr with the image you downloaded (in my case pbasto/shiori)

This ensures that your bookmarks and data are preserved even if the container is removed.
 To stop the container, use docker stop shiori, and to restart it, use docker start shiori.

Go to login page: http://localhost:8080/logins

Default user:pass
shiori:gopher


---
## 🚀 Using Your Docker Hub Image

### Option 1: Using Docker Compose (Recommended)

```bash
# Start the container with data persistence
docker-compose -f docker-compose.prod.yaml up -d

# Stop the container
docker-compose -f docker-compose.prod.yaml down

# Update to latest version
docker-compose -f docker-compose.prod.yaml pull
docker-compose -f docker-compose.prod.yaml up -d
```

### Option 2: Using Docker Directly

```bash
# Run the container with data persistence
docker run -d \
  --name shiori_prod \
  -p 8080:8080 \
  -v ~/shiori/data:/shiori \
  -e SHIORI_DIR=/shiori \
  --restart unless-stopped \
  pbasto/shiori:latest

# Stop the container
docker stop shiori_prod

# Update to latest version
docker pull pbasto/shiori:latest
docker stop shiori_prod
docker rm shiori_prod
# Then run the docker run command again
```

## 💾 Data Persistence

Your bookmark data will be stored in `~/shiori/data` on your host machine. This directory will contain:

- `shiori.db` - SQLite database with your bookmarks
- Configuration files
- Any downloaded content

## 🔧 Configuration Options

You can configure Shiori using environment variables:

```bash
# Example with additional configuration
docker run -d \
  --name shiori_prod \
  -p 8080:8080 \
  -v ~/shiori/data:/shiori \
  -e SHIORI_DIR=/shiori \
  -e SHIORI_HTTP_ROOT_PATH=/bookmarks \
  -e SHIORI_DATABASE_URL=mysql://user:password@host/shiori \
  --restart unless-stopped \
  pbasto/shiori:latest
```

## 📱 Accessing Your Shiori Instance

After starting the container, you can access Shiori at:

- **Local Access**: `http://localhost:8080`
- **Remote Access**: `http://your-server-ip:8080`

## 🔄 Updating Your Deployment

To update to a new version when you push updates:

```bash
# Using docker-compose
docker-compose -f docker-compose.prod.yaml pull
docker-compose -f docker-compose.prod.yaml up -d

# Using docker directly
docker pull pbasto/shiori:latest
# Then restart your container with the new image
```

Restart shiori with 
`docker restart shiori`

Manually
`docker exec -it shiori /bin/bash`

Start a container with the "always" or "unless-stopped" restart policy
`docker run -d --restart unless-stopped  --name shiori -p 8080:8080`

---


### Alternative 
After building the image you will be able to start a container from it. To preserve the data, you need to bind the directory for storing database and thumbnails. In this example we're binding the data directory to our current working directory :

`docker run -d --rm --name shiori -p 8080:8080 -v $(pwd):/srv/shiori techknowlogick/shiori`
The above command will :

- Creates a new container from image techknowlogick/shiori.
- Set the container name to shiori (option --name).
- Bind the host current working directory to /srv/shiori inside container (option -v).
- Expose port 8080 in container to port 8080 in host machine (option -p).
- Run the container in background (option -d).
- Automatically remove the container when it stopped (option --rm).

After you've run the container in background, you can access console of the container :

`docker exec -it shiori sh`
Now you can use shiori like normal. If you've finished, you can stop and remove the container by running :

`docker stop shiori`




---


[![IC](https://github.com/go-shiori/shiori/actions/workflows/push.yml/badge.svg?branch=master)](https://github.com/go-shiori/shiori/actions/workflows/push.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/go-shiori/shiori)](https://goreportcard.com/report/github.com/go-shiori/shiori)
[![#shiori-general:matrix.org](https://img.shields.io/badge/matrix-%23shiori-orange)](https://matrix.to/#/#shiori:matrix.org)
[![Containers](https://img.shields.io/static/v1?label=Container&message=Images&color=1488C6&logo=docker)](https://github.com/go-shiori/shiori/pkgs/container/shiori)

**Check out our latest [Announcements](https://github.com/go-shiori/shiori/discussions/categories/announcements)**

Shiori is a simple bookmarks manager written in the Go language. Intended as a simple clone of [Pocket][pocket]. You can use it as a command line application or as a web application. This application is distributed as a single binary, which means it can be installed and used easily.

![Screenshot][screenshot]

## Features

- Basic bookmarks management i.e. add, edit, delete and search.
- Import and export bookmarks from and to Netscape Bookmark file.
- Import bookmarks from Pocket.
- Simple and clean command line interface.
- Simple and pretty web interface for those who don't want to use a command line app.
- Portable, thanks to its single binary format.
- Support for sqlite3, PostgreSQL, MariaDB and MySQL as its database.
- Where possible, by default `shiori` will parse the readable content and create an offline archive of the webpage.
- [BETA] [web extension][web-extension] support for Firefox and Chrome.

![Comparison of reader mode and archive mode][mode-comparison]

## Documentation

All documentation is available in the [docs folder][documentation]. If you think there is incomplete or incorrect information, feel free to edit it by submitting a pull request.

## License

Shiori is distributed under the terms of the [MIT license][mit], which means you can use it and modify it however you want. However, if you make an enhancement for it, if possible, please send a pull request.

[documentation]: https://github.com/go-shiori/shiori/blob/master/docs/index.md
[mit]: https://choosealicense.com/licenses/mit/
[web-extension]: https://github.com/go-shiori/shiori-web-ext
[screenshot]: https://raw.githubusercontent.com/go-shiori/shiori/master/docs/assets/screenshots/cover.png
[mode-comparison]: https://raw.githubusercontent.com/go-shiori/shiori/master/docs/assets/screenshots/comparison.png
[pocket]: https://getpocket.com/
[256]: https://github.com/go-shiori/shiori/issues/256
