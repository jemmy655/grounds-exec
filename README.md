# grounds-exec
[ ![Codeship Status for grounds/grounds-exec](https://codeship.io/projects/8bd7b600-2357-0132-4e4e-7e9ae55fd39f/status?branch=master)](https://codeship.io/projects/36679)

This project is a server with real-time bidirectional event-based communication, 
used by [Grounds](http://beta.42grounds.io) to execute arbitry code within various
languages inside Docker containers.

`grounds-exec` support many languages and make it really trivial to add support
for other languages.

## Languages

There is one Docker image for each language stack supported.

Checkout this
[documentation](https://github.com/grounds/grounds-exec/blob/master/docs/NEW_LANGUAGE.md)
to get more informations about how to add support for a new language stack.

grounds-exec currently supports latest version of:

- C
- C++
- C#
- Go
- PHP
- Python 2 and 3 
- Ruby

## Server

All you need is `docker >= 1.3`, `fig >= 1.0` and `make` to run this project inside
Docker containers with the same environment as in production.

This project is using [socket.io](http://socket.io). This adds the ability 
to run arbitrary code in real-time from a web browser.

Each `run` is executed inside a Docker container, which is destroyed at the end
of the `run`.

A container automatically timeouts 10 seconds after the beginning of a `run`.

If a `run` request is sent from the same client when a previous `run` request is
already running, this previous request will be gracefully interrupted.

### First build language stack images

    make images
    
The first build takes a lot of time. If you want you can also pull official images:

    make images-pull
    
If you want to push these images to your own repository:
    
    REPOSITORY="<you repository>" make images-push

You need to specify a docker remote API url to connect with.

    export DOCKER_URL="https://127.0.0.1:2375"

Nb: If your are using docker API through `https`, your `DOCKER_CERT_PATH` will be
mounted has a volume inside the container.

Be careful: `boot2docker` enforces tls verification since version 1.3.
   
### Launch you own server

    make run

### Connect to the server

    var client = io.connect('http://localhost:8080');

### Send a run request

    client.on('connect', function(data) {
        client.on('run', function(data){
            console.log(data);
        });
        client.emit('run', { language: 'python2', code: 'print 42' });
    });
    
### Run response

Format:

    { stream: 'stream', chunk: 'chunk' }
    
Typicall response:

    { stream: 'start',  chunk: '' }
    { stream: 'stdout', chunk: '42\n' }
    { stream: 'stderr', chunk: 'Error!\n' }
    { stream: 'status', chunk: 0 }

The server has a spam prevention against each `run` request. The minimum 
delay between two run request is fixed to 0.5 seconds.

In this case, you will receive for each ignored request:

    { stream: 'ignored',  chunk: '' }

If an error occured during a `run`, you will receive:

    { stream: 'error', chunk: 'Error message' }

### Tests

Tests will also run inside `docker` containers with the same environment
as the CI server.

To run the test suite:

    make test

To run specific test files or add a flag for `mocha` you can specify `TEST_OPTS`:
    
    TEST_OPTS="test/utils.js" make test

## Contributing

Before sending a pull request, please checkout the contributing
[guidelines](/docs/CONTRIBUTING.md).

## Licensing

`grounds-exec` is licensed under the MIT License. See `LICENSE` for full license
text.
