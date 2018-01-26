# tizen-msp-bus-tracker
A Vue.js app running as a Tizen Web Application to track MetroTransit bus geo-location data and schedule for whatever stops you want on your Gear S3 watch. (Currently stops are hardcoded to ones I use with plans to add ability to customize this in the future)

Biggest goals were rapid development and avoiding using TizenStudio all-together since I was having trouble with it.

## Doin stuff

- make sure you have TizenStudio installed (or at least the CLI stuff) with some important stuff in your .(bash|zsh)rc 
``` bash
export PATH="$HOME/tizen-studio/tools:$PATH"
export PATH="$HOME/tizen-studio/tools/ide/bin:$PATH"
export PATH="$HOME/tizen-studio/tools/emulator/bin:$PATH"
```


``` bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
# (looks like a pretend watch minus the Tizen APIs but hey you can debug and live reload!)
npm run dev

# build for production with minification
npm run build

# run the tizen emulator (currently hardcoded to my emulator)
npm run emulator

# deploy to a s3 tizen wearable (currently hardcoded to my watches IP on my home network)
npm run s3
```
