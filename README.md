# thirst-alert-app

This repo contains source code for the ThirstAlert Flutter app. All data used by the app is server by an Express.js backend, with source code at [this repo](https://github.com/thirst-alert/thirst-alert-be).

## Get started with local development

### Prerequisites

Flutter installed - follow [these instructions](https://docs.flutter.dev/get-started/install)

### Instructions

1. Duplicate the `.env.template` file and rename to `.env`. change the value of `BASE_URL` to either
   - `<ip>:<port>` where ip and port are the local ip and port of a machine running the backend mentioned above locally on your network
   - `https://api.dev.thirst-alert.com` to use a already deployed backend
2. Run `flutter run` with a physical device connected to your pc and selected in flutter command line tool or with an emulator selected in flutter command line tool
