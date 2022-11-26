# Borg backup runner

<https://www.borgbackup.org/>

Borg documentation: <https://borgbackup.readthedocs.io/en/stable/>

## Setup

- Clone the repo
- Copy the `sample.config` directory to `config`
- Edit `config/borg.env` and add your config options
- Edit `exclude.txt` and `include.txt` with your requirements. One entry per line
- From the root of the repo, run `./borg.sh init` to initialize the repo
- Use crontab (or the scheduler of your choice) to run `./borg.sh backup automated` periodically

## env file

As this file contains your backup passphrase, make sure to secure it by giving it permission 600.

Comment out a option to use its default.

All options are prefixed with `BORG_`. It's just removed below to make the table nicer to read on GitHub.

| Option              | Default                    | Required     | Description                                                                                                                 |
| ------------------- | -------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------- |
| `BACKUP_PASSPHRASE` | n/a                        | Yes          | Generate a secure password to protect the backup. `pwgen -s 64 1`. **Make sure to backup this.**                            |
| `KEYFILE`           | `scriptDir/config/keyfile` | No           | Full path to the keyfile to encrypt backups with. Path cannot exist, it is generated by Borg. **Make sure to backup this.** |
| `LOG_FILE`          | `scriptDir/borg.log`       | No           | Full path to the script log file                                                                                            |
| `REMOTE`            | `false`                    | No           | Back up to a remote target over SSH                                                                                         |
| `REMOTE_DOMAIN`     | n/a                        | <sup>1</sup> | FQDN or IP of the Borg backup server/target                                                                                 |
| `REMOTE_USER`       | n/a                        | <sup>1</sup> | Username to log in to `BORG_REMOTE_DOMAIN`                                                                                  |
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
