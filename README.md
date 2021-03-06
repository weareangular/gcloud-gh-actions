# GitHub Actions for Gcloud

This Action for [Gcloud](https://cloud.google.com/) enables arbitrary actions with the `gcloud` command-line sdk.

<div align="center">
<img src="https://github.githubassets.com/images/modules/site/features/actions-icon-actions.svg" height="80"></img>
&nbsp;&nbsp;
&nbsp;&nbsp;
&nbsp;&nbsp;
&nbsp;&nbsp;
&nbsp;&nbsp;
&nbsp;&nbsp;
&nbsp;&nbsp;
&nbsp;&nbsp;
<img src="https://www.gstatic.com/devrel-devsite/prod/vf8bcd170103a60a9457e3a7682d3f70251c619395c6349d20b56cd2a80761a19/cloud/images/cloud-logo.svg" height="80"></img>
</div>

## Inputs

- `--deploy-container-app [APP_NAME]` - deploy container app gcloud run.
  - `[APP_NAME]` - is the name of the app where it should be deployed.
- `args` - **Required**. This is the arguments you want to use for the `gcloud` sdk.

## Environment variables

- `GCLOUD_CREDENTIALS` - **Required**. The token to use for authentication.
- `REGION` - Region to deploy the app (Only applicable if script run with `--deploy-container-app`).

## Example

To authenticate with Gcloud sdk, and deploy container in Gcloud RUN:

```yaml
name: Build and deploy in Gcloud (Production)
on:
  push:
    branches:
      - main

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: weareangular/gcloud-gh-actions@dev
        with:
          args: --deploy-container-app ${{ secrets.APP_NAME }}
        env:
          GCLOUD_CREDENTIALS: ${{ secrets.GOOGLE_APPLICATION_CREDENTIALS }}
          REGION: ${{ secrets.REGION }}
```
