<template>
  <div id="app">
    <BusTracker/>
  </div>
</template>

<script>
import BusTracker from './components/BusTracker'

export default {
  name: 'App',
  components: {
    BusTracker
  }
}

console.log('Bus Tracker Started!')
</script>

<style>
html,
body {
  margin: 0;
  padding: 0;
  height: 360px;
  width: 360px;
  font-family: sans-serif;
}

#app {
  background-color: #000;
  color: #fff;
  position: relative;
  border-radius: 50%;
  font-size: 1em;
  font-weight: bold;
  text-align: center;
  height: 100%;
}
</style>
