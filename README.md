## ASDF & direnv demo

### Setup

Install [asdf](https://asdf-vm.com/guide/getting-started.html) core.

Install the [asdf-direnv plugin](https://github.com/asdf-community/asdf-direnv#setup).

## The demo

### Per project tooling

The `go` directory has the `.envrc` and `.tool-versions` files in place to use a specific version of `golang` and `golangci-lint`

For the very first time you use this directory you will need to allow `direnv` to run and install the asdf plugins you're missing. `asdf` will tell you which ones these are 

```shell
$ cd go
direnv: error <path>/asdf-demo/go/.envrc is blocked. Run `direnv allow` to approve its content
$ direnv allow
$ asdf install
golangci-lint plugin is not installed
golang plugin is not installed
```

Install the plugins and then run install to install the tools defined in `.tool-versions`
```shell
$ asdf plugin add golangci-lint
$ asdf plugin add golang
$ asdf install
$ direnv reload
```

Now you should have the versions in your path 
```shell
$ go version
go version go1.18.3 darwin/arm64
$  golangci-lint version
golangci-lint has version 1.46.1 built from 044f0a17 on 2022-05-12T09:23:45Z
```

If you leave this directory then the tools will no longer be in your path. Note that you get some helpful explanation from `asdf` though
```shell
$ cd ..
direnv: unloading
$ golangci-lint version
No version is set for command golangci-lint
Consider adding one of the following versions in your config file at $HOME/.tool-versions
golangci-lint 1.46.1
```

### Other useful features
#### Dynamically changing path / setting ENV variables
$PATH is dynamically changed depending on the plugins you use in the `.tool-versions` file. For example, as we are using the `golang` plugin then both `$GOPATH` and `$GOROOT` is exported to our environment, and also `$GOPATH` is added to our `$PATH`. For example

```shell
$ cd go 
......
direnv: export +GOPATH +GOROOT +MIX_ARCHIVES +MIX_HOME ~PATH

# Lets install a handy go binary
$ go install github.com/rakyll/hey@latest
.......

# Is that in our path ?
$ type hey
hey is /Users/jon/.asdf/installs/golang/1.18.3/packages/bin/hey

# Lets use it
$ hey https://www.bbc.co.uk
```

And when you leave that directory the changes to your environment are undone

#### Running tools from IDEs / elsewhere
If you want to run the exact same tools as you've set up from other locations / programs you can use the `asdf exec` command. For example

```shell
$ cd $HOME
$ direnv exec <path to checkout>/asdf-demo/go golangci-lint version
```

### Further reading
More useful [pro-tips](https://github.com/asdf-community/asdf-direnv#pro-tips) 