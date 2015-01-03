## Release Script

There is now a release bash script that automates this process
called `release/publish.sh`

Only use the below steps if you are unable to use the publish script.

## Tips on releasing

```sh
$ rake build
$ rake release # will push gem, and importantly, tag the gem
```
