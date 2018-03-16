This is a dockerfile setup for [taskserver](https://github.com/GothenburgBitFactory/taskserver)


# How to build your own taskserver in Docker

Make your own certs (the ones referenced in entrypoint.sh). Taskserver comes
with some cert generation scripts you can use if you want.

Initialize users by making an `init-orgs` folder in a `tasks` folder and
`touch` a file for each user. You'll be mounting this folder in your container.

For a first time run, you want something like this:


```bash
$ tree tasks
tasks
├── init-orgs
│   └── your-org-name-here
│       ├── username1
│       └── username2
└── ssl
    ├── api.cert.pem
    ├── api.key.pem
    ├── ca.cert.pem
    ├── ca.key.pem
    ├── server.cert.pem
    ├── server.crl.pem
    └── server.key.pem
```


The taskd user needs write access to `tasks`.

You also probably want to listen on quad zeros instead of localhost. But maybe
not, I don't know your setup who am I to know how you set your things up?

Anyway. Once your tasks folder is setup somewhere with certs and probably a
user or two, build and run this with:

```bash
$ docker build -t taskserver .
$ docker run -d \
    --name=taskserver \
    --hostname=taskserver \
    -e TASKD_HOSTNAME=0.0.0.0 \
    -p 7358:7358 \
    -v /my/safe/space/tasks:/tasks \
    taskserver
```

Tail the logs (`docker logs -f taskserver`) to find your unique user ID... or
look at the files in the mounted `tasks` folder to find the user string. Dump
something like this in your `~/.taskrc` to config your client:

```ini
taskd.certificate=/home/you/.task/your-user.cert.pem
taskd.key=/home/you/.task/your-user.key.pem
taskd.ca=/home/you/.task/ca.cert.pem
taskd.server=your.domain.tld:7358
taskd.credentials=your-org/your-user/12345678-abcd-efgh-ijkl-901234567890
```

You should be able to `task sync init` if you have dns setup for your domain
and you're not firewalled.
