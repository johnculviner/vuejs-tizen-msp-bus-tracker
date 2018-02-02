<template>
  <div>
    <button v-on:click="nextStop" class="route-selector">
      <div>{{currentStop.route}} @</div>
      <div>{{currentStop.location}}</div>
      <div class="position-indicators">
        <div class="position-indicator" v-bind:class="{ active: stop === currentStop }" v-bind:key="stop.stopNumber" v-for="stop in stops"></div>
      </div>
    </button>
    <div class="view">
      <h2>
        {{nowString}}&nbsp;
        ⚙ :{{getTimeTillRefresh()}}
      </h2>
      <div v-if="isRefreshing" class="cog">⚙</div>
      <h3 class="no-busses" v-if="!times.length">No scheduled buses!</h3>
      <ul>
        <li v-bind:key="x.scheduledDeparture" class="time" v-for="x in times">
          <span class="route">{{ x.route }}</span>
          <span v-if="x.distanceMiles">
          {{ x.nextTripText }} -
          {{ x.distanceMiles }}mi
        </span>
          <span>
            {{ x.scheduledDeparture }}
          </span>
        </li>
      </ul>
    </div>
    <button v-on:click="refreshCurrentStop" class="refresh-stop">
      Refresh
    </button>
  </div>
</template>

<script>

import get from 'lodash.get'

const stops = [
  {route: '6', location: '50th & Xerxes', stopNumber: 6243, lat: 44.912357, long: -93.318793},
  {route: '6', location: '44th & France', stopNumber: 1292, lat: 44.921891, long: -93.329013},
  {route: '146', location: 'Marquette & 10th', stopNumber: 53305, lat: 44.973523, long: -93.273283},
  {route: '146', location: 'Marquette & 4th', stopNumber: 53302, lat: 44.979315, long: -93.268434},
  {route: '6', location: 'Hennepin & 10th', stopNumber: 17924, lat: 44.975879, long: -93.277893}
]

export default {
  data () {
    return {
      stops: stops,
      currentStop: stops[0],
      times: [],
      isRefreshing: false,
      nowString: new Date().toLocaleTimeString(),
      lastUpdate: new Date()
    }
  },
  created () {
    // attach event handlers
    Tizen('power.request', x => x('SCREEN', 'SCREEN_NORMAL'))
    document.addEventListener('rotarydetent', ev => ev.detail.direction === 'CW' ? this.nextStop() : this.prevStop())
    setInterval(() => {
      this.nowString = new Date().toLocaleTimeString()
      if (new Date() - this.lastUpdate > 30000) {
        this.refreshCurrentStop()
      }
    }, 1000)
    document.addEventListener('tizenhwkey', function (e) {
      console.log('Exiting Bus Tracker!')
      tizen.application.getCurrentApplication().exit()
    })

    this.refreshCurrentStop()
  },
  methods: {
    getTimeTillRefresh () {
      const time = 30 - Math.round((new Date() - this.lastUpdate) / 1000)
      return time < 10 ? `0${time}` : time
    },
    nextStop () {
      this.currentStop = stops[stops.indexOf(this.currentStop) + 1]
      if (!this.currentStop) { this.currentStop = stops[0] }
      this.refreshCurrentStop()
    },
    prevStop () {
      this.currentStop = stops[stops.indexOf(this.currentStop) - 1]
      if (!this.currentStop) { this.currentStop = stops[stops.length - 1] }
      this.refreshCurrentStop()
    },
    refreshCurrentStop () {
      const currentStop = this.currentStop
      this.isRefreshing = true
      this.lastUpdate = new Date()

      fetchCb(`http://svc.metrotransit.org/NexTrip/${currentStop.stopNumber}?format=json`, resp => {
        this.isRefreshing = false
        this.times = resp
          .filter(x => x.Route === currentStop.route)
          .map(x => ({
            route: x.Route + x.Terminal,
            scheduledDeparture: get12HourTime(new Date(parseInt(/\((.*?)-/.exec(x.DepartureTime)[1]))),
            nextTripText: x.DepartureText,
            distanceMiles: x.VehicleLatitude ? latLongDistance(x.VehicleLatitude, x.VehicleLongitude, currentStop.lat, currentStop.long).toFixed(2) : null
          }))
      })
    }
  }
}

function latLongDistance (lat1, lon1, lat2, lon2) {
  const radlat1 = Math.PI * lat1 / 180
  const radlat2 = Math.PI * lat2 / 180
  const theta = lon1 - lon2
  const radtheta = Math.PI * theta / 180
  let dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta)
  dist = Math.acos(dist)
  dist = dist * 180 / Math.PI
  dist = dist * 60 * 1.1515
  return dist
}

function fetchCb (url, cb) {
  const xhr = new XMLHttpRequest()
  const method = 'GET'

  xhr.open(method, url, true)
  xhr.onreadystatechange = function () {
    if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
      cb(JSON.parse(xhr.responseText))
    }
  }
  xhr.send()
}

function get12HourTime (date) {
  return date.toLocaleTimeString().replace(/([\d]+:[\d]{2})(:[\d]{2})(.*)/, '$1$3')
}

function Tizen (apiPath, func) {
  if (!window.tizen) return

  try {
    func(get(tizen, apiPath))
  } catch (e) {
    console.log('caught error')
    console.log(JSON.stringify(e))
  }
}

</script>

<style>
button {
  padding: 5px 10px;
  display: inline-block;
  background-color: #005b79;
  color: white;
  font-size: 1.2em;
  position: fixed;
  left: 0;
  width: 100%;
  border: 0;
  font-weight: bold;

}
.route-selector {
  top: 0;
  padding-top: 5px;
  padding-bottom: 5px;
}

.position-indicator {
  display: inline-block;
  height: 10px;
  width: 10px;
  background-color: #666666;
  margin-right: 10px;
  border-radius: 5px;
}

.active {
  background-color: white;
}

.refresh-stop {
  position: fixed;
  padding-bottom: 15px;
  padding-top: 10px;
  bottom: 0;
  left: 0;
}

.view {
  padding-top: 60px;
  padding-bottom: 40px;
  font-size: 1.2em;
}

.time {
  color: white;
  font-size: 1em;
  text-align: left;
  list-style: none;
  margin-bottom: 15px;
  clear: both;
  padding-left: 10px;
}

.route {
  background-color: green;
  padding: 2px 5px;
}

.cog {
  font-size: 6em;
  position: absolute;
  width: 100%;
  text-align: center;
}

.no-busses {
  color: red;
}
</style>
