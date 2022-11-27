# Borg backup runner

<!--
Borg backup runner. Wrapper script for basic borg backup features.
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

<https://www.borgbackup.org/>

Borg documentation: <https://borgbackup.readthedocs.io/en/stable/>

## Setup

- Clone the repo
- Copy the `sample.config` directory to `config`
- Edit `config/borg.env` and add your config options
- Edit `exclude.txt` and `include.txt` with your requirements. One entry per line
- From the root of the repo, run `./borg.sh --init` to initialize the repo
- Use crontab (or the scheduler of your choice) to run `./borg.sh --backup --automated` periodically
- If you need to run multiple profiles, you can use the `--config` option to specify different config files

## env file

As this file contains your backup passphrase, make sure to secure it by giving it permission 600.

Comment out a option to use its default.

All options are prefixed with `BORG_`. It's just removed below to make the table nicer to read on GitHub.

| Option              | Default                    | Required     | Description                                                                                                                 |
| ------------------- | -------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------- |
| `BACKUP_PASSPHRASE` | n/a                        | Yes          | Generate a secure password to protect the backup. `pwgen -s 64 1`. **Make sure to backup this.**                            |
| `BACKUP_PREFIX`     | `hostname-`                | No           | Backup name prefix                                                                                                          |
| `COMPACT_ON_BACKUP` | `true`                     | No           | Run compact after every backup                                                                                                |
| `KEEP_DAILY`        | `7`                        | No           | Keep this many daily backups                                                                                                |
| `KEEP_HOURLY`       | `2`                        | No           | Keep this many hourly backups                                                                                               |
| `KEEP_MONTHLY`      | `12`                       | No           | Keep this many monthly backups                                                                                              |
| `KEEP_WEEKLY`       | `4`                        | No           | Keep this many weekly backups                                                                                               |
| `KEEP_WITHIN`       | `24H`                      | No           | Keep all backups in this period                                                                                             |
| `KEEP_YEARLY`       | `-1` (infinitely)          | No           | Keep this many yearly backups                                                                                               |
| `KEYFILE`           | `scriptDir/config/keyfile` | No           | Full path to the keyfile to encrypt backups with. Path cannot exist, it is generated by Borg. **Make sure to backup this.** |
| `LOG_FILE`          | `scriptDir/borg.log`       | No           | Full path to the script log file                                                                                            |
| `PRUNE_ON_BACKUP`   | `true`                     | No           | Run prune after every backup                                                                                                |
| `REMOTE_DOMAIN`     | n/a                        | <sup>1</sup> | FQDN or IP of the Borg backup server/target                                                                                 |
| `REMOTE_PORT`       | 22                         | No           | Port to connect to `BORG_REMOTE_DOMAIN`                                                                                     |
| `REMOTE_USER`       | n/a                        | <sup>1</sup> | Username to log in to `BORG_REMOTE_DOMAIN`                                                                                  |
| `REMOTE`            | `false`                    | No           | Back up to a remote target over SSH                                                                                         |
| `SSH_PRIVKEY`       | n/a                        | <sup>1</sup> | Full path to the private SSH key used to log in to `BORG_REMOTE_DOMAIN`. Cannot be password protected                       |
| `TARGET_DIRECTORY`  | n/a                        | Yes          | Full path to backup target directory. Local or remote                                                                       |
| `WEBHOOK_ENABLE`    | `false`                    | No           | Enable logging to webhook                                                                                                   |
| `WEBHOOK_URL`       | n/a                        | <sup>2</sup> | Your webhook URL                                                                                                            |

- <sup>1</sup> Required if `BORG_REMOTE=true`
- <sup>2</sup> Required if `BORG_WEBHOOK_ENABLE=true`

## Webhook logging

This is developed for use with [Matrix-Hookshot](https://github.com/matrix-org/matrix-hookshot) generic webhooks. Add
the Transformation JavaScript from `hookshot_webhook_js_transformation.js` to enable @room mentions for errors. Make
sure you give the webhook appservice user permissions to @room. However, this should work with any webhook reader that
accepts unauthenticated `PUT` JSON requests with the key `text`. To edit the behavior, edit the `webhook` function in
`src/utils.js` to fit your needs.
