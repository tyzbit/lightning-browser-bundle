# lightning-browser-bundle
Browser bundle with an included and integrated Lightning daemon.

# Prerequisites

Linux (Debian-like) System (PRs for support for more systems welcomed!)
[Docker](https://store.docker.com/search?type=edition&offering=community)
Chromium (will be installed via `apt` if it isn't already)

# Install

Run `./install.sh` and follow the directions.
(currently assumes debian-like linux system)

Write down and save the wallet seed somewhere safe.

# Prepare

Visit http://localhost:8280/ to see the `lncli-web` interface.

From here, you can generate a new address to fund your lnd daemon
and open channels.

# Use

Launch Chromium, install [Lightning Experience](https://github.com/erkarl/lightning-experience/),
then configure the extension.

Leave the LND REST setting alone

Use `sudo xxd -p -c 1000 ~/.lnd-bb/admin.macaroon` to get your admin
macaroon, paste it into the config area, then click Save.

Now, browse around, and when you're presented with an invoice the
extension will pop up with an easy-to-use button to pay the invoice.

# Backup

Your lnd folder, by default, is in ~/.lnd-bb and is owned by root.
As long as you're not running as root(DON'T), this actually improves security from
the desktop perspective as even you can't read the wallet files. This makes backing
it up more difficult, though.

I suggest backing the folder up with overwriting backups since you always want 
the latest backup to restore from to help guard against breaching your channels.

Do not restore from backup without good reason.
