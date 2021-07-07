<template>
  <div class="CaptchaContent">
    <span class="ContactFormLabel">Test de sécurité</span>
    <div class="CaptchaInputsWrapper">
      <span class="CaptchaInstruction"
        >Veuillez recopier le code <b>{{ captchaRef }}</b> ci-après :</span
      >
      <input
        v-model="captchaUser"
        class="ContactFormInput CaptchaInput no-bottom-margin"
        type="text"
      />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    captchaRef: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    captchaUser: '',
  }),
  watch: {
    captchaUser(newVal) {
      this.$emit('captchaUser', newVal)
    },
  },
}
</script>

<style scoped>
.CaptchaContent {
  display: flex;
  flex-direction: column;
}

.CaptchaInputsWrapper {
  margin-bottom: 24px;
  display: flex;
  align-items: center;
}

.CaptchaInstruction {
  margin-right: 10px;
}

.CaptchaInput {
  width: 62px;
}
</style>
