# First Steps

Log into your web browser and go to the server's IP address (e.g.
<https://your-server/>). The default setup will redirect HTTP requests to
HTTPS.


![Figure: Elephant Shed portal Setup](images/portal_01_init.png)
On first Launch the ElephantShed needs to be provisioned. This step can alternatively
be done by adding all Hosts of the ElephantShed to `/etc/elephant-shed-portal/hostlist`.

If Multihost-Clustering is required, it is essential for the users credentials to be
valid on all systems.

The Elephant Shed portal provides information about
running PostgreSQL instances and their status. Moreover you get
access to all other installed components.

The server will ask you for your user credentials. Depending on the
deployment process the required user will differ. On a test
installation (e.g. using Vagrant) the initial user is **admin** with
password **admin**. See also: [Users](users.html). All bundled components except
for pgAdmin4 have been configured to use PAM authentication.

pgAdmin4 doesn't support PAM authentication yet. It has its own user
management system which is decoupled from all system users. You should
have been asked about the initial user within the installation
setup. If you deployed a Vagrant VM the initial user is **admin@localhost**
and **admin** as password.

On a new installation you will find one cluster running the current PostgreSQL major version with the name `main`.

The configuration for clusters can be found in `/etc/postgresql/<major version>/<name>/`.

To use PostgreSQL from external application servers only a few steps are needed.

1. Open a shell connection to the server using SSH or shellinabox <https://your-server/shellinabox>.

2. Switch to user `postgres` and launch psql:
    * `sudo -u postgres psql`

3. Create a database and corresponding application user, options:
    * `psql: CREATE ROLE appuser1 WITH LOGIN PASSWORD 'testpass';`
    * `psql: CREATE DATABASE appdb1 OWNER appuser1;`

4. Allow external access for your application servers, your network or everyone. Configuration file: `/etc/postgresql/<major version>/<name>/pg_hba.conf`

5. (optional) Make desired configuration changes and tuning. `/etc/postgresql/<major version>/<name>/postgresql.conf`

6. Reload the configuration, options:
    * Portal: Click on the button `Service` next to the cluster and choose "Reload" from the dropdown menu
    * `psql`: `SELECT pg_reload_conf();`

7. (optional) Configure a superuser to be able to use pgAdmin4 <https://your-server/pgadmin4> or other management tools
    * Create password for user postgres: `\password`
    * Create personalized superusers: `CREATE USER "sosna" SUPERUSER;`, `\password "sosna"`

