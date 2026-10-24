# Personal Gmail workspace: public legal pages

Added on October 24, 2026. These pages are intentional local customizations and
must survive future upstream pulls, merges, and image rebuilds.

## Public URLs and scope

- Privacy policy: <https://chatooos.com/privacy>
- Terms of service: <https://chatooos.com/terms>

Both documents are English, server-rendered, and publicly accessible without a
login. They describe a personal workspace connecting the operator's own Gmail
accounts, including Gmail permissions, data use and storage, optional
integrations, revocation, and deletion. Contact information and document content
live in `en.legal_pages`; no OAuth credentials belong in these files.

These URLs are intended for Google Console Branding. Adding the pages does not
change Google OAuth callbacks, enable integrations, publish the OAuth app, or
establish that Google has verified the app.

## Files to preserve

| File                                    | Required local behavior                                                                              |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `app/controllers/legal_controller.rb`   | Public privacy and terms actions with fixed English document selection.                              |
| `app/views/layouts/legal.html.erb`      | Shared document layout, navigation, contact links, accessibility, and production stylesheet loading. |
| `app/views/legal/show.html.erb`         | Shared server-rendered document sections.                                                            |
| `app/javascript/entrypoints/legal.scss` | Dedicated stylesheet using existing Tailwind and theme utilities.                                    |
| `tailwind.legal.config.js`              | Reuses the main Tailwind configuration and scans the legal templates.                                |
| `config/routes.rb`                      | Top-level named `/privacy` and `/terms` routes.                                                      |
| `config/locales/en.yml`                 | Complete `en.legal_pages` content and shared labels.                                                 |

Merge upstream route and translation changes alongside these entries. Keep
existing application customizations too. Do not restore whole files from
upstream or an old snapshot to resolve conflicts. If upstream changes the
controller or asset infrastructure, adapt this feature to it while preserving
the public URLs and behavior.

After an upstream merge, review these files and entries before building. After
building, verify anonymous GET and HEAD responses for both URLs, the production
CSS response, document content, navigation, and mobile/light/dark rendering when
the relevant layout or styling changed. Check that no login redirect or session
cookie is introduced. The existing `scripts/verify-customizations.sh` covers
other fork customizations and does not verify these legal pages.

## Published release evidence

- Implementation commit: `39d37284e0`.
- Image source revision: `e17b7ecb114a7f0d6a1473d61afefcb8dd6f0360`.
- Published image: `smusiczz/chatwoot:release-4.19.0`, `linux/amd64`.
- October 24 publication digest:
  `sha256:818f2e05e597f5cb77a403d8ce1aa6b19d327b70ec33eccbd531c7e7ae473098`.

The tag can move in later releases; the digest identifies this specific image.
Image-level validation passed anonymous document GET/HEAD requests, compiled CSS
loading, source checksums, SDK compatibility, and runtime checks. Full release
evidence and validation limits are recorded in `tasks/todo.md`. Public-domain
availability depends on deploying the image.

## Updating an existing deployment

Run these commands on the server, in the existing deployment directory, using
the same Compose file and project selection as the running application. The
inspected deployment configuration names the services `rails` and `sidekiq`.
If the server uses another Compose filename, add the same `-f` option to each
command.

First ensure both services resolve to this image:

```yaml
image: smusiczz/chatwoot:release-4.19.0
```

The outer workspace's example `docker-compose.yml` still references an older
release. Do not assume the server's configuration already uses the new tag.
Check the resolved image names without printing environment variables:

```sh
docker compose config --images
```

For a deployment already running this fork's 4.19.0 release, pull the updated
image and recreate only the application services:

```sh
docker compose pull rails sidekiq
docker compose up -d --no-deps --no-build --force-recreate rails sidekiq
docker compose ps rails sidekiq
docker compose logs --tail=100 rails sidekiq
```

Pulling downloads the image; recreating the containers selects it. Compose
preserves mounted volumes. This command sequence leaves the existing database
and cache services running and requires them to be available. The legal-page
change adds no database migrations. If the deployed application is older than
4.19.0, follow the intervening release upgrade process, including the database
backup and preparation appropriate to that upgrade.

Confirm the deployed public documents return HTTP 200 without authentication:

```sh
curl --fail --head https://chatooos.com/privacy
curl --fail --head https://chatooos.com/terms
```

Then open both URLs in a signed-out browser, confirm the text and styles load,
and enter the URLs in Google Console Branding.

Docker command references:
[compose pull](https://docs.docker.com/reference/cli/docker/compose/pull/) and
[compose up](https://docs.docker.com/reference/cli/docker/compose/up/).
