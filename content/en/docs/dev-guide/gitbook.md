# Building the documentation
Stroom's documentation is built using [GitBook (external link)](https://www.gitbook.com). 

## Prerequisites
### NPM
You need NPM to install the GitBook command line toolchain. To get NPM install [node (external link)](https://nodejs.org/en/).

### GitBook command line tools

```bash
npm install -g gitbook-cli
```

## Build the book
GitBook uses plugins, e.g. anchorjs allows us to create links to headings within a file. You need to install these plugins first. The below commands should be run in the project root.

```bash
gitbook install
```

You can build the documentation like this:

```bash
gitbook build
```

Or you can run the GitBook server which will watch your files as you work and server them on `localhost:4000`.

```bash
gitbook serve
```

## Troubleshooting

### I get an error when trying to run `gitbook serve`
If you see `Errpr: watch /path/to/stroom ENOSPC` then run the following: 
`echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p`

### Links don't work when I load `_book/index.html`
It won't, because [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) is not and cannot be enabled when viewing local files. You need to run `gitbook serve` or if you really don't want to do that try `cd _book && python -m SimpleHTTPServer`.
