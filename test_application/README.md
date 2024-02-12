# README

## Playing with API:

Prepare dev and test environment: 

```bash
docker-compose build 
docker-compose run app rails db:create
docker-compose run app rails db:migrate
docker-compose run app rails db:seed
```

Run test only:
```bash
docker-compose run test
```

Poke with testing in terminal:
```bash
docker-compose run test /bin/bash 
# then do whatever you want like in usual terminal
```

How to poke and play with store API:
```bash
docker-compose up
```

Then open browser on 0.0.0.0:3000 and you are ready to go! 

## How the things are done
4 Years ago I summarized an approach to the API testing via its documentation:
[Code-Document-Test](https://leshchuk.medium.com/code-test-document-9b79921307a5)
( Updated it btw during this coding challenge. Since I'm referring to it, let it be in a better shape )

This sample application is written on top of this approach and on top of some helpers I wrote over a time for swaggerizing rails-API apps. 
* All the swaggerizer code could be found in the lib folder. I would consider it a black-box, but you can dig if you want though :)
* API definitions could be found inside app_doc folder: models definitions, apis definitions and some reusables.
* Go to test/integration folders to examine API testing process. I suggest you to comment some tests to see what's happened


