Release notes for project onezone
=================================

CHANGELOG
---------

### 20.02.14

-   **VFS-8482** Added dedicated page for privacy policy content.
-   **VFS-8326** Web GUI: added service name and domain information on
    control panel login screen.

### 20.02.13

### 20.02.12

-   **VFS-8196** Add support for sets in OAI PMH. Every handle service
    is considered a separate set, and all handles created using a handle
    service belong to its corresponding set.

### 20.02.11

-   **VFS-8016** Added option to POSIX storage driver to use different
    root UID and GID than 0.
-   **VFS-7995** Added custom Root UID and Root GID options for POSIX
    storage.
-   **VFS-7741** Web GUI: showing proper error information page when
    there is no on-line supporting provider for share.

### 20.02.10

### 20.02.9

### 20.02.8

### 20.02.7

-   **VFS-7413** Fixed displaying users with the same full name on
    members views.
-   **VFS-7321** Added REST API endpoint for blocking and unblocking
    user accounts. Blocked user is denied access to all Onedata services
    unless their account is unblocked again.
-   **VFS-7294** Added publicly available REST endpoints for fetching
    information and data of shared files/directories. The data-related
    endpoints are offered by Onezone, which redirects to a suitable
    Oneprovider so that a guest user does not need any knowledge of the
    environment to access the data. Improved the Web GUI's shares view
    to present the public endpoints in an easy-to-use manner.
-   **VFS-7280** Fixed page reload after Let's Encrypt certificate
    generation via Onepanel GUI.
-   **VFS-7165** Add a workaround for Erlang's SSL implementation that
    would not reload server certificate chain when it is changed (e.g.
    after Let's Encrypt certificate regeneration).
-   **VFS-6638** Fixed handling duplicate clusters states on clusters
    list in GUI.
-   **VFS-6566** Improved UX and fixed minor issues in share views.
    Fixed inability to open share hosted by Oneprovider 19.02.x using
    Onezone 20.02.x.


### 20.02.6

-   **VFS-6802** Added visual QoS expression editor with live matching
    storages evaluation.

### 20.02.5

-   **VFS-7124** Fixed adding user mapping to LUMA local feed on POSIX
    incompatible storages.
-   **VFS-6999** Improve error reporting in entrypoints of
    oneprovider/onezone dockers, always dump application logs to stdout
    in case of failures during batch deployment.
-   **VFS-6858** Added support for cancelling storage auto-cleaning run
    using GUI.
-   **VFS-6745** Added new view with token templates in tokens creator
    GUI.

### 20.02.4

-   **VFS-7003** Added new counters presenting progress of current/last
    finished scan of the storage import mechanism - number of all
    processed files (\`Processed files\`) and the total number of files
    residing on the storage during the scan (\`Total storage files\`).
-   **VFS-6958** Added new endpoint that checks correctness of a QoS
    expression and returns the list of storages that match the
    expression.
-   **VFS-6841** Introduce unified time management in all Onedata
    components - all clusters now regularly synchronize their clocks
    with the Onezone service, the process is managed by Onepanel's
    master node.


### 20.02.3

### 20.02.2

-   **VFS-6853** Matching session cookie is now required to verify a GUI
    access tokens (they are used behind the scenes by the Onedata web
    applications), which increases security.
-   **VFS-6852** Fixed Oneprovider and Onezone services not showing in
    tokens creator's service caveat list when user had no access to
    service cluster.
-   **VFS-6845** Prevent application from stopping until all documents
    are correctly persisted in order to improve resistance to temporary
    database errors.
-   **VFS-6732** New JSON and RDF metadata editor based on Ace Editor.
-   **VFS-6563** All entities avaliable in Onezone REST (users, group,
    spaces, providers etc) now include the creator and creation time in
    the returned details.
-   **VFS-6456** Show more details about lack of privileges when trying
    to perform various actions in GUI.
-   **VFS-6338** Enhanced API of the mechanism for importing existing
    data into Onedata spaces without need for copying the data. The
    mechanism is now called "storage import". Introduced modes of
    storage import: "manual" which allows for manual registration of
    files and "auto" which enables automatic detection and import of
    files from the storage. Introduced possibility to forcefully
    start/stop scans of auto storage import. Redesigned GUI related to
    storage import, adjusted to the new features.


### 20.02.1

-   **VFS-6645** Optimize changes querrying.
-   **VFS-6628** Extended harvesting configuration - it is now possible
    to select harvesting options, like metadata types to harvest or
    additional file details (fileName, spaceId), upon index creation.
    New metadata types are now harvestable - xattrs and rdf. Default
    values of HarvestingBackendType and HarvestingBackendEndpoint can
    now be set by Onezone admin - if set, these values can be omitted
    when creating a new harvester. New option (retry\_on\_rejection)
    allowing for all payloads rejected by the harvesting backend to be
    automatically analysed for offending data (e.g. fields that do not
    match the schema), pruned and submitted again.
-   **VFS-6568** Introduced concept of readonly storage. If enabled,
    Oneprovider will block any operation that writes, modifies or
    deletes data on the storage. Such storage can only be used to import
    data into the space. Mandatory to ensure proper behaviour if the
    backend storage is actually configured as readonly.
-   **VFS-6535** Updated S3 SDK library to 1.8.7.
-   **VFS-6518** Endpoint is now optional when adding a new harvester -
    if not provided, the default one from Onezone configuration will be
    used. Generic GUI is now loaded by default upon harvester creation.
-   **VFS-6504** Added HTTP storage helper allowing registration of HTTP
    and HTTPS servers as storage sources for Onedata Spaces.
-   **VFS-6474** Added initial support for XRootD storage, including
    direct access to XRootD storages and importing of legacy data sets
    stored on XRootD or EOS servers.
-   **VFS-6462** Every file in a space is now harvested - including
    files without metadata. Harvested metadata now has a new key -
    \`\_\_onedata\` - which contains file name, space id and xattrs.
-   **VFS-6457** Added new publicly visible field to shares -
    description (supports the markdown format).
-   **VFS-6453** New Open Data and share description views with visual
    Dublin Core editor and Markdown editor.
-   **VFS-6421** New generic GUI plugin for harvesters.
-   **VFS-6378** Onepanel GUI and REST API now explicitly block
    supporting a space with more than one imported storage (globally) -
    such operation was possible in the past but was never supported by
    the internal storage import logic and led to incoherent view on
    space data.
-   **VFS-6358** Optimization of files upload through GUI.
-   **VFS-6346** GUI improvements: added Oneprovider GUI notifications,
    better file selection, additional error handling, better file
    manager refresh UX, fixed overflow of context menu in file browser,
    fixes in responsive layout.
-   **VFS-6344** GUI: showing information if QoS requirement is
    impossible to be fulfilled.
-   **VFS-6343** Added delete account feature in GUI.
-   **VFS-6288** Basic HA functionality (experimental) - protect
    Oneprovider from single node failure.
-   **VFS-6287** Integrate traverse pools with HA sub-system.
-   **VFS-6261** Integrate high-level services with HA sub-system.
-   **VFS-6184** Added the space owner concept. Space owner works like
    \"root\" within the space - such user is allowed to perform all
    file/API operations, regardless of the assigned privileges and file
    permissions / ACLs. Ownership can be assigned to any number of
    users, and it is forbidden to leave a space without an owner -
    ownership must be transferred first.
-   **VFS-6167** Allow nodes adding and deleting in-fly basing on HA
    sub-system.
-   **VFS-5648** Extended QoS expression to allow comparators (\<, \>,
    \<=, \>=) and numeric values. Changed \"-\" operator to \"\\\".
    Space characters (\" \"), dashes (\"-\") and underscores (\"\_\")
    are now allowed in QoS parameters. Added more details to invalid QoS
    expression errors.
-   **VFS-4760** Added implicit API caveats that limit access tokens
    used by Onedata GUIs behind the scenes for authentication and
    authorization. Different services in the system are presented with
    user\'s access token with power limited to bare minimum required for
    the service to handle user requests. For example, Oneproviders do
    not have access to APIs that could alter or delete user data and
    memberships.

### 20.02.0-beta4

### 20.02.0-beta3

-   VFS\_6131 Account for changes in emergency passphrase api changes
-   VFS-5838 entrypoint: Accept any 2xx and 3xx HTTP codes as success
-   VFS-5841 entrypoint: Use PyYAML\'s safe loader to silence a warning
-   VFS-5841 Parse deployment error using new onepanel errors format
-   VFS-5742 Disabled http\_proxy for normal operation
-   VFS-5742 Disabled yum mirrors for package tests
-   VFS-5742 Disabled yum proxy for package tests
-   VFS-5742 Enabled proxy cache for package tests
-   VFS-5742 Enabled proxy cache for docker builds

### 19.02.5

### 19.02.4

-   **VFS-6631** Rtransfer takes into account storage block size
    choosing blocks to synchronize.
-   **VFS-6607** Fix node restart with HA disabled.
-   **VFS-6402** Disallowed creating more than one public handle for a
    single share.
-   **VFS-6401** All authentication errors are now wrapped in
    UNAUTHORIZED error and map to 401 HTTP code to avoid ambiguity when
    reporting token related errors - tokens can be used for
    authentication as well as input data for some operations (e.g.
    invite tokens).
-   **VFS-6390** Because of asynchronous processing, it was possible
    that GraphSync session cleanup intertwined with deleted record
    cleanup (that removes corresponding subscriptions from sessions,
    possibly including the session being cleaned up) and caused an error
    that interrupted change propagation. Now, if the session is no
    longer existent, subscription removal errors are ignored and the
    propagation completes.
-   **VFS-6369** Fix datastore internal call, batch management during
    links listing and infinite loop during storage directories creation.

### 19.02.3

-   Minor bugfixes

### 19.02.2

-   Bugfixes and stability improvements

### 19.02.1

-   VFS-5884 Added print\_package\_versions makefile rule

##### oz-worker

-   VFS-5936 Improve entitlement mapping *Merge entitlements with
    different roles (privileges) to the highest of them* Store previous
    privileges to discover and coalesce later changes in user roles
-   VFS-5940 Rename GUI package verification envs to more intuitive
-   VFS-5205 Hide share CREATE and DELETE operations from Onezone REST
    API (as they are reserved for Oneprovider logic), return rootFileId
    as ObjectID in share details

##### onepanel

-   VFS-5994 Make \'production\' Let\'s Encrypt mode the default
-   VFS-5940 Rename oz-worker\'s GUI package verification envs to more
    intuitive

### 19.02.0-rc2

-   Releasing new version 19.02.0-rc2

### 19.02.0-rc1

-   VFS-5660 Disabled RANDFILE to enable certificate creation in Docker
-   VFS-5660 Added libssl1.0.0 dependency to Docker
-   VFS-5660 Fixed git has abrrev length
-   VFS-5660 Updated onezone dockerfile for Ubuntu Bionic
-   VFS-5657 Changed onezone package architecture for Ubuntu
-   VFS-5657 Fixed Dockerfile for tagged ubuntu packages
-   VFS-5657 Updated make\_deb Makefile rules for bionic

### 18.02.3

-   Releasing new version 18.02.3

### 18.02.2

-   Update submodules
-   VFS-5436 Fixed Xenial package tests
-   VFS-5434 Fixed CentOS package tests

### 18.02.1

-   VFS-5154 Updated Onezone package test deployment configs
-   Fix badly formatted apt-get command in Dockerfile
-   added iproute, dnsutils, and iperf3 packages to Dockerfile

### 18.02.0-rc13

-   Releasing new version 18.02.0-rc13

### 18.02.0-rc12

-   Fix locale settings in Onezone docker

### 18.02.0-rc11

-   Releasing new version 18.02.0-rc11

### 18.02.0-rc10

-   Releasing new version 18.02.0-rc10

### 18.02.0-rc9

-   VFS-4532 Create new config file instead of using regexps
-   VFS-4367 Do not fail cluster restart when admin credentials are
    missing
-   VFS-4367 Expect 409 when configuring existing cluster

### 18.02.0-rc8

-   Releasing new version 18.02.0-rc8

### 18.02.0-rc7

-   VFS-4474 Display error details on configuration error
-   VFS-4278 Better detection of bad credentials error in entrypoint

### 18.02.0-rc6

-   Releasing new version 18.02.0-rc6

### 18.02.0-rc5

-   Releasing new version 18.02.0-rc5

### 18.02.0-rc4

-   VFS-4278 Change log message in docker entrypoint
-   VFS-4278 Use nagios to wait for cluster to resume work
-   VFS-4278 Wait for rest listener to start
-   VFS-4278 Allow failed configuration for existing deployment

### 18.02.0-rc3

-   Releasing new version 18.02.0-rc3

### 18.02.0-rc2

-   Releasing new version 18.02.0-rc2

### 18.02.0-rc1

-   Releasing new version 18.02.0-rc1

### 18.02.0-beta6

-   Releasing new version 18.02.0-beta6

### 18.02.0-beta5

-   VFS-3622 Merged docker-dev with docker. Added possibility to run
    service from sources
-   VFS-4267 Enable building using OpenSSL 1.1.0 dependencies

### 18.02.0-beta4

-   Releasing new version 18.02.0-beta4

### 18.02.0-beta3

-   VFS-4213 Change the way persistent volume is created to allow for
    mounting single files inside it

### 18.02.0-beta2

-   VFS-4126 Remove obsolete port exposes from Dockerfiles

### 18.02.0-beta1

-   Releasing new version 18.02.0-beta1

### 17.06.2

-   Releasing new version 17.06.2

### 17.06.1

-   Releasing new version 17.06.1

### 17.06.0-rc9

-   Releasing new version 17.06.0-rc9

### 17.06.0-rc8

-   VFS-3815 Switched dnf to yum in packaging tests
-   VFS-3815 Added prefix to package builder images
-   VFS-3815 Modified packaging tests for CentOS 7

### 17.06.0-rc7

-   Releasing new version 17.06.0-rc7

### 17.06.0-rc6

-   Releasing new version 17.06.0-rc6

### 17.06.0-rc5

-   Releasing new version 17.06.0-rc5

### 17.06.0-rc4

-   Releasing new version 17.06.0-rc4

### 17.06.0-rc3

-   Releasing new version 17.06.0-rc3

### 17.06.0-rc2

-   Releasing new version 17.06.0-rc2

### 17.06.0-rc1

-   Releasing new version 17.06.0-rc1

### 17.06.0-beta6

-   Releasing new version 17.06.0-beta6

### 17.06.0-beta4

-   Releasing new version 17.06.0-beta4

### 17.06.0-beta3

-   VFS-3353 Enable user name/email set in update\_refs.sh
-   Releasing new version 17.06.0-beta3

### 17.06.0-beta2

-   VFS-3348 Update couchbase version to 4.5.1

### 3.0.0-rc16

-   Releasing new version 3.0.0-rc16

### 3.0.0-rc15

-   Releasing new version 3.0.0-rc15
-   VFS-3197 Enable release docker to log to stdout
-   Update refs to
    origin/feature/VFS-3213-change-storage-verification-mechanism.

### 3.0.0-rc14

-   Update refs to origin/release/3.0.0-rc14.
-   Releasing new version 3.0.0-rc14
-   Deps update

### 3.0.0-rc14

-   Releasing new version 3.0.0-rc14

### 3.0.0-rc13

-   Releasing new version 3.0.0-rc13

### 3.0.0-rc12

-   Enable graceful stop on SIGTERM
-   Update refs to origin/release/3.0.0-rc12.
-   VFS-2901 Refactor packages tests
-   VFS-2733 Add excluded path to docker entrypoint

### 3.0.0-rc11

-   Releasing new version 3.0.0-rc11

### 3.0.0-rc10

-   Releasing new version 3.0.0-rc10

### 3.0.0-rc9

-   Releasing new version 3.0.0-rc9

### 3.0.0-rc8

-   Releasing new version 3.0.0-rc8

### 3.0.0-rc7

-   VFS-2633 Use specific package builders

### 3.0.0-rc6

-   VFS-2582 Using GUI fix for blank notifications
-   VFS-2390 Upgrade rebar to version 3

### 3.0.0-rc5

-   Update WebGUI
-   Update one panel for extended configuration options

### 3.0.0-rc4

-   Add ONEPANEL\_DEBUG\_MODE env variable to release docker entrypoint

### 3.0.0-RC3

-   VFS-2156 Update release docker
-   VFS-2156 Update packages tests
-   Use environment variables for packages build

### 3.0.0-RC2

-   Enable Symmetric Multiprocessing
-   Add admin endpoints to add/remove users and groups from spaces, fix
    a couple of bugs
-   Turn off HSTS by default, allow configuration via app.config,
    improve docs integration
-   Use environment variables for packages build

### 3.0.0-RC1

-   VFS-2316 Update etls.
-   VFS-2250 Use wrappers for macaroon serialization

### 3.0.0-beta8

-   minor changes and improvements

### 3.0.0-beta7

-   Update oz\_worker reference
-   Deps update
-   Update onepanel reference
-   Releasing new version 3.0.0-beta7
-   Deps update

### 3.0.0-beta6

-   Update refs to orgin/develop.
-   Update oz-worker ref
-   Releasing new version 3.0.0-beta6
-   Deps update
-   VFS-2163 Update references
-   fix unrecognized py.test option
-   Update refs to origin/develop.
-   update bamboos
-   VFS-2062 Update docker entrypoint

### 3.0.0-beta7

-   Update oz GUI

### 3.0.0-beta6

-   Update refs to orgin/develop.
-   Update oz-worker ref
-   Releasing new version 3.0.0-beta6
-   Deps update
-   VFS-2163 Update references
-   fix unrecognized py.test option
-   Update refs to origin/develop.
-   update bamboos
-   VFS-2062 Update docker entrypoint

### 3.0.0-beta6

-   Add basic authorization (login and password)

### 3.0.0-beta5

-   Support for nested groups.

### 3.0.0-beta3

-   Update GUI.
-   Update subscriptions.
-   Change levels for several datastore models.

### 3.0.0-beta1

-   update oz\_worker with subscriptions
-   VFS-1757 Rename packaging directory to docker.
-   VFS-1757 Fix onezone deinstallation.

### 3.0.0-alpha3

-   First version of onezone on the basis of globalregistry.

------------------------------------------------------------------------

Generated by sr-release.
