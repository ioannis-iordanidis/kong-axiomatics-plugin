## How to use

### Build and start Kong
```
docker-compose build --force-rm && docker-compose up -d
```

### Stop Kong
```
docker-compose down
```

### Stop Kong as well as remove Docker volume to be able to start from scratch
```
docker-compose down -v
```
