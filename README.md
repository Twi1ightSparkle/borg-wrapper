# Borg backup runner

<https://www.borgbackup.org/>

Borg documentation: <https://borgbackup.readthedocs.io/en/stable/>

## Setup

- Clone the repo
- Copy the `sample.config` directory to `config`
- Edit `config/borg.env` and add your config options
- Edit `exclude.txt` and `include.txt` with your requirements. One entry per line
- From the root of the repo, run `./borg.sh init` to initialize the repo
- Use crontab (or the scheduler of your choice) to run `./borg.sh backup` periodically

## env file

As this file contains your backup passphrase, make sure to secure it by giving it permission 600.

Comment out a option to use its default.

<table>
    <thead>
        <tr>
            <th>Option</th>
            <th>Default</th>
            <th>Required</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>BORG_WEBHOOK_ENABLE</th>
            <td><code>false</code></td>
            <td>No</td>
            <td>Enable logging to webhook</td>
        </tr>
        <tr>
            <th>BORG_WEBHOOK_URL</th>
            <td>n/a</td>
            <td>Yes, if `BORG_WEBHOOK_ENABLE=true`</td>
            <td>Your webhook URL</td>
        </tr>
        <tr>
            <th>BORG_LOG_FILE</th>
            <td><code>scriptDirectory/borg.log</code></td>
            <td>No</td>
            <td>Full path to the script log file</td>
        </tr>
        <tr>
            <th>BORG_KEYFILE</th>
            <td><code>scriptDirectory/config/keyfile`</code></td>
            <td>No</td>
            <td>Full path to the keyfile to encrypt backups with</td>
        </tr>
        <tr>
            <th>BORG_PASSWORD</th>
            <td>n/a</td>
            <td>Yes</td>
            <td>Generate a secure password to protect the backup. pwgen -s 64 1</td>
        </tr>
        <tr>
            <th></th>
            <td></td>
            <td></td>
            <td></td>
        </tr>
    </tbody>
</table>

## Webhook logging

This is developed for use with [Matrix-Hookshot](https://github.com/matrix-org/matrix-hookshot) generic webhooks. Add
the Transformation JavaScript from `hookshot_webhook_js_transformation.js` to enable @room mentions for errors. Make
sure you give the webhook appservice user permissions to @room. However, this should work with any webhook reader that
accepts unauthenticated `PUT` JSON requests with the key `text`. To edit the behavior, edit the `webhook` function in
`src/utils.js` to fit your needs.
