<template>
  <div>
    <h1>Page de prospection</h1>
    <span> Envelope : {{ envelope }} </span><br />
    <span>
      ----------------------------------------------------------------------------------
    </span>
    <prospecting-map
      :areas-data="areasData"
      @envelopeUpdated="updateEnvelope"
    />
  </div>
</template>

<script>
import ProspectingMap from '~/components/ProspectingMap.vue'

export default {
  components: {
    'prospecting-map': ProspectingMap,
  },
  async asyncData({ $axios }) {
    const areasData = await $axios.$get(
      `http://127.0.0.1:8888/api/v1/area_knowledge_level/M10?limit=50`
      // `http://127.0.0.1:8888/api/v1/area_knowledge_level/M10?limit=50&envelope=${}`
    )
    return { areasData }
  },
  data: () => ({
    envelope: null,
  }),
  methods: {
    updateEnvelope(envelope) {
      this.envelope = envelope
    },
  },
}
</script>
