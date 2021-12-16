import Vue from 'vue'
import { LMap, LGeoJson, LControl, LTileLayer } from 'vue2-leaflet'
import 'leaflet/dist/leaflet.css'
const VueLeaflet = {
  install(Vue, options) {
    Vue.component('l-map', LMap)
    Vue.component('l-control', LControl)
    Vue.component('l-tile-layer', LTileLayer)
    Vue.component('l-geo-json', LGeoJson)
  },
}
Vue.use(VueLeaflet)
export default VueLeaflet
