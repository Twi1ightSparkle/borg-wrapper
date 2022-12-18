# Borg wrapper

<!--
Borg wrapper. An (almost) no-dependency wrapper script for basic Borg backup features.
Copyright (C) 2022  Twilight Sparkle

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
-->

I don't recommend relying on this script in production yet. Or, at least, frequently review and verify your backups.

<https://www.borgbackup.org/>

Borg documentation: <https://borgbackup.readthedocs.io/en/stable/>

## Setup

- Download and extract the latest [release](https://github.com/Twi1ightSparkle/borg-wrapper/releases)
- Copy the `sample.config` directory to `config`
- Edit `config/borg.env` and add your config options
- Add a secure passphrase to the first line of the `borg_passphrase` file
- Edit `exclude.txt` and `include.txt` with your requirements. One entry per line
- From the root of the repo, run `./borg-wrapper.sh --init` to initialize the repo
- Use crontab (or the scheduler of your choice) to run `./borg-wrapper.sh --backup --automated --live` periodically.
See `crontab_example` for an example configuration
- If you need to run multiple profiles, you can use the `--config` option to specify a different config directory

See [src/help.sh](https://github.com/Twi1ightSparkle/borg/blob/main/src/help.sh) for all command line options.

## env file

Comment out an option to use its default.

| Option                   | Default                            | Required     | Description                                                                                                                                         |
| ------------------------ | ---------------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `BACKUP_PASSPHRASE_FILE` | `configDirectory/ borg_passphrase` | No           | Full path to the file containing the passphrase. **Make sure you protect and back up this file**                                                    |
| `BACKUP_PREFIX`          | `hostname-`                        | No           | Backup name prefix                                                                                                                                  |
| `COMPACT_ON_BACKUP`      | `true`                             | No           | Run compact after every backup                                                                                                                      |
| `EXCLUDE_FILE`           | `configDirectory/ exclude.txt`     | No           | Full path to the file with list of paths to exclude in the backup                                                                                   |
| `INCLUDE_FILE`           | `configDirectory/ include.txt`     | No           | Full path to the file with list of paths to include in the backup                                                                                   |
| `KEEP_DAILY`             | `7`                                | No           | Keep this many daily backups                                                                                                                        |
| `KEEP_HOURLY`            | `2`                                | No           | Keep this many hourly backups                                                                                                                       |
| `KEEP_MONTHLY`           | `12`                               | No           | Keep this many monthly backups                                                                                                                      |
| `KEEP_WEEKLY`            | `4`                                | No           | Keep this many weekly backups                                                                                                                       |
| `KEEP_WITHIN`            | `24H`                              | No           | Keep all backups in this period                                                                                                                     |
| `KEEP_YEARLY`            | `-1` (infinitely)                  | No           | Keep this many yearly backups                                                                                                                       |
| `KEYFILE`                | `configDirectory/ keyfile`         | No           | Full path to the keyfile to encrypt backups with. The file cannot exist; Borg generates it. **Make sure you protect and back up this file**         |
| `LOG_FILE`               | `configDirectory/ borg.log`        | No           | Full path to the script log file                                                                                                                    |
| `PRUNE_ON_BACKUP`        | `true`                             | No           | Run prune after every backup                                                                                                                        |
| `REMOTE_DOMAIN`          | n/a                                | <sup>1</sup> | FQDN or IP of the Borg backup server/target                                                                                                         |
| `REMOTE_PORT`            | `22`                               | No           | Port to connect to `REMOTE_DOMAIN`                                                                                                                  |
| `REMOTE_SSH_PRIVKEY`     | n/a                                | <sup>1</sup> | Full path to the private SSH key used to log in to `REMOTE_DOMAIN`. Cannot be password protected                                                    |
| `REMOTE_USER`            | n/a                                | <sup>1</sup> | Username to log in to `REMOTE_DOMAIN`                                                                                                               |
| `REMOTE`                 | `false`                            | No           | Back up to a remote target over SSH                                                                                                                 |
| `TARGET_DIRECTORY`       | n/a                                | Yes          | Full path to the backup target directory. Local or remote                                                                                           |
| `WEBHOOK_ENABLED`        | `false`                            | No           | Enable logging to webhook                                                                                                                           |
| `WEBHOOK_URL`            | n/a                                | <sup>2</sup> | Your webhook URL                                                                                                                                    |
| `WEBHOOK_VERBOSE`        | `true`                             | No           | More verbose webhook logging. Set to false to only send a single message at the end of a successful operation. Only affects `--backup` and `--init` |

- <sup>1</sup> Required if `REMOTE=true`
- <sup>2</sup> Required if `WEBHOOK_ENABLED=true`

## Webhook logging

This is developed for use with [Matrix-Hookshot](https://github.com/matrix-org/matrix-hookshot) generic webhooks. Add
the Transformation JavaScript from `hookshot_webhook_js_transformation.js` to enable @room mentions for errors. Make
sure you give the webhook appservice user permissions to @room. However, this should work with any webhook reader that
accepts unauthenticated `PUT` JSON requests with the key `text`. To edit the behavior, edit the `webhook` function in
`src/utils.js` to fit your needs.

## Mac

On Mac, you must give `cron` full disk access.

- In the terminal, enter `open /usr/sbin`
- Go to `System Settings` -> `Privacy & Seurity` -> `Full Disk Access`
- From Finder, drag `cron` into the `Full Disk Access` window
