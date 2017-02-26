# binpkgbot: Robot builds Gentoo binpkg in clean environment, automatically and continuously.

When you manage many Gentoo servers, I guess you're tired to run `emerge -uDN @world` and wait for all servers, or to install same packages in your all servers.  Portage has binpkg feature, which allows to re-use prebuilt binaries when `emerge`ing packages.

Binpkgbot allows you to build binpkg in clean environment, automatically and continuously!  Continuous building of the latest packages also allows you to run `-uDN` anytime you want.

## Features

- Build in clean environment
  - Runs emerge on clean stage3 using systemd-nspawn every run
  - Fetch and install existing binpkg of build dependencies
  - Builds binpkg of new dependencies
- 2 build modes:
  - Attempt to upgrade existing stage3 directory
  - Just install additional packages

## Prerequisites

- systemd based Linux box
- systemd-nspawn
  - with btrfs filesystem

## Installation

    $ gem install binpkgbot

## Usage

### Set up

1. Prepare stage3 (or 4) directory (e.g. `/mnt/vol/stage`)
  - binpkgbot adds modification when running upgrades. Otherwise it's used as base of ephemeral container
  - this directory should be in a btrfs filesystem
2. `/etc/portage` directory outside of (1) (e.g. `/mnt/vol/etc-portage`)
  - binpkgbot always copies the entire directory into a container
3. gentoo portage repository (e.g. `/usr/portage`)
  - binpkgbot syncs the specified directory; if this behavior is acceptable, you can specify `/usr/portage`.

then write some yml:

``` yaml
# binpkgbot.yml
stage: /mnt/vol/stage
etc_portage: /mnt/vol/etc-portage
portage_repo: /usr/portage

# use_sudo_for_nspawn: true

# emerge_options:
#   - '-v'
# config_protect_mask: false

## bind mounts for a container
# binds:
#   - /opt/my-overlay # default to read-only
#   - rw: /tmp/something_writable # or 'ro:'

#   - from: /mnt/vol/packages
#     to: /usr/portage/packages
#     writable: true
#   - from: /mnt/vol/elog
#     to: /var/log/portage/elog
#     writable: true

tasks:
  # Upgrade the stage (-uDN)
  - upgrade: '@world' # emerge -uDN @world
  - install:
      atom: '@preserve-rebuild'
      persist: true # Run sd-nspawn without --ephemeral option, default to false.


  # Simple way
  - install: 'sys-apps/dstat'
  # Complex way
  - install:
      atom: 'media-apps/ffmpeg'
      ## Using these flag modifier (:use, :accept_keywords, :unmasks, :masks) to define variants.
      use: x265
      ## or
      # use:
      #   - x265
      #   # to other packages
      #   - media-libs/x265 numa
      accept_keywords: true # default to ~*
      # accept_keywords:
      #   - true
      #   # - "~amd64"
      #   ## to other packages
      #   - "media-libs/x265 ~amd64"
      #   - media-libs/x265 # or default: ~*
      unmask: true # unmask a specified atom itself
      # unmask:
      #   - true
      #   - media-libs/x265
      # mask: 
      #   - media-libs/x264

  - include: ./task.yml # use file instead
  - include: ./task.d/* # or glob files and run all of them (order by filename)

## run something inside or outside a container
#   - run:
#       ## run outside of container? (default to false)
#       # host: true
#       ## persist change in a container (default to true)
#       # persist: false
#       script:
#         - emerge-webrsync
```

```
# ./task.yml
- install: ...
```

### Running

```
$ binpkgbot
$ binpkgbot -c path/to/binpkgbot.yml

$ binpkgbot --help
$ binpkgbot --version
```

## Recommended practices

- Turn on `binpkg-multi-instance` and `getbinpkg` in `$FEATURES`
  - These are optional. Put them by yourself into `make.conf`.
- Maintain different `/etc/portage` directory then put all common use flags, keywords, and unmaskings in the directory.
  - minimize USE flag difference. Use `use:` `accept_keywords:` `unmask:` for a case needs to make a variant of builds.

    (e.g. `app-analyzer/zabbix` has a flag to build `server` or go only with `agent`. Server needs both, but most servers are okay with having `agent` only. Then we need 2 variants in `zabbix` binpkg, so use `use:` configuration to build variants.)

    ``` yaml
    - install:
        atom: app-analyzer/zabbix
        use:
          - agent
          - server
    - install:
        atom: app-analyzer/zabbix
        use:
          - agent
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/binpkgbot.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

