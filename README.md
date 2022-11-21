# Borg backup runner

<https://www.borgbackup.org/>

Documentation: <https://borgbackup.readthedocs.io/en/stable/>

This script is inspired by <https://github.com/krispayne/borg-scripts>

## Setup

- Clone the repo
- Copy the `sample.config` directory to `config`
- Edit `config/borg.env` and add your config options
- Edit `exclude.txt` and `include.txt` with your requirements. One entry per line
- From the root of the repo, run `./borg.sh init` to initialize the repo
- Use crontab (or the scheduler of your choice) to run `./borg.sh backup` periodically

## Webhook logging

This is developed for use with [Matrix-Hookshot](https://github.com/matrix-org/matrix-hookshot) generic webhooks. Add
the Transformation JavaScript from `hookshot_webhook_js_transformation.js` to enable @room mentions for errors. Make
sure you give the webhook appservice user permissions to @room. However, this should work with any webhook reader that
accepts unauthenticated `PUT` JSON requests with the key `text`. To edit the behavior, edit the `webhook` function in
 `src/utils.js` to fit your needs.
