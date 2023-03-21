<template>
  <v-container fluid>
    <main class="TopSection breadcrumb">
      <breadcrumb />
      <header>
        <h3 v-show="!validForm" class="fw-600 text-center">
          J'aimerais vous faire part de retours sur le site
        </h3>
      </header>
    </main>
    <section v-show="!validForm" class="Section">
      <div class="ContactFormContent">
        <span class="black02 fw-500 bottom-margin-8">Nom</span>
        <input
          v-model="userName"
          type="text"
          placeholder="Henri Martin"
          class="ContactFormInput"
        />
        <span v-show="alerts.noUserName" class="ContactFormAlert">
          Veuillez renseigner votre nom
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span class="black02 fw-500 bottom-margin-8">Adresse email</span>
        <input
          v-model="userMail"
          type="email"
          placeholder="henri.martin@monmail.fr"
          class="ContactFormInput"
        />
        <span v-show="alerts.noUserMail" class="ContactFormAlert">
          Veuillez renseigner votre adresse email
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span v-show="alerts.wrongUserMail" class="ContactFormAlert">
          Veuillez renseigner une adresse email valide
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span class="black02 fw-500 bottom-margin-8">
          À quel sujet souhaitez-vous nous contacter ?
        </span>
        <menu class="SelectorMenu">
          <div
            v-for="(item, index) in subjectsList"
            :key="index"
            class="SelectorItem"
            :class="item === selectedSubject ? 'selected' : ''"
            @click="updateSelectedSubject(item)"
          >
            {{ item }}
          </div>
        </menu>
        <span v-show="alerts.noSelectedSubject" class="ContactFormAlert">
          Veuillez sélectionner un sujet pour votre demande
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span class="black02 fw-500 bottom-margin-8">Message</span>
        <textarea
          v-model="userMessage"
          placeholder="Bonjour..."
          class="ContactFormTextarea"
        />
        <span v-show="alerts.noUserMessage" class="ContactFormAlert">
          Veuillez écrire un message
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <captcha-form
          :captcha-ref="captchaRef"
          @captchaUser="updateCaptchaUser"
        />
        <span v-show="alerts.wrongCaptchaUser" class="ContactFormAlert">
          Le code de sécurité que vous avez renseigné n'est pas bon
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <span v-show="alerts.sendingFail" class="ContactFormAlert">
          L'envoi du mail a échoué...
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlert"
          ></i>
        </span>
        <button
          :disabled="disabledButton"
          class="PrimaryButton"
          @click="validateForm"
        >
          Envoyer
        </button>
      </div>
    </section>
    <contact-form-confirmation v-show="validForm" />
  </v-container>
</template>

<script>
import Breadcrumb from '~/components/layouts/Breadcrumb.vue'
import CaptchaForm from '~/components/about/CaptchaForm.vue'
import ContactFormConfirmation from '~/components/about/ContactFormConfirmation.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
    'captcha-form': CaptchaForm,
    'contact-form-confirmation': ContactFormConfirmation,
  },
  data: () => ({
    userName: '',
    userMail: '',
    selectedSubject: null,
    userMessage: '',
    captchaRef: '',
    captchaUser: '',
    alerts: {
      noUserName: false,
      noUserMail: false,
      wrongUserMail: false,
      noSelectedSubject: false,
      noUserMessage: false,
      wrongCaptchaUser: false,
      sendingFail: false,
    },
    subjectsList: ['Problème technique', 'Design', 'Autre'],
    emailConfig: '',
    validForm: false,
    disabledButton: false,
  }),
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
  mounted() {
    this.captchaRef = this.$generateCaptcha()
  },
  methods: {
    updateSelectedSubject(subject) {
      this.selectedSubject = subject
      // console.debug(this.selectedSubject)
    },
    updateCaptchaUser(captcha) {
      this.captchaUser = captcha
    },
    validateForm() {
      for (const i in this.alerts) {
        this.alerts[i] = false
      }
      if (!this.userName) {
        this.alerts.noUserName = true
      } else if (!this.userMail) {
        this.alerts.noUserMail = true
      } else if (!this.$checkEmail(this.userMail)) {
        this.alerts.wrongUserMail = true
      } else if (!this.selectedSubject) {
        this.alerts.noSelectedSubject = true
      } else if (!this.userMessage) {
        this.alerts.noUserMessage = true
      } else if (this.captchaUser !== this.captchaRef) {
        this.alerts.wrongCaptchaUser = true
      } else {
        // this.validForm = true
        this.disabledButton = true
        const messageIntroduction = `Nom : ${this.userName} \nEmail : ${this.userMail} \nSujet : ${this.selectedSubject} \n\nMessage : \n`
        this.selectedSubject === 'Problème technique'
          ? (this.emailConfig = 'technique')
          : this.selectedSubject === 'Design'
          ? (this.emailConfig = 'design')
          : (this.emailConfig = 'generalfeedback')
        this.$mail
          .send({
            config: this.emailConfig,
            subject:
              "[Atlas ODF] J'aimerais vous faire part de retours sur le site",
            text: messageIntroduction + this.userMessage,
          })
          .then((response) => {
            // console.debug(response)
            this.validForm = true
          })
          .catch((error) => {
            this.alerts.sendingFail = true
            this.disabledButton = false
            if (error.response) {
              console.debug(error.response.data)
            }
          })
      }
    },
    deleteAlert() {
      for (const i in this.alerts) {
        this.alerts[i] = false
      }
    },
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}

.TopSection {
  padding: 16px 5% 0;
}
</style>
