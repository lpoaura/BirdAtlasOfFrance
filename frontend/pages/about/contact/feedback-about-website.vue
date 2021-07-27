<template>
  <v-container fluid>
    <header class="ContactFormHeader">
      <breadcrumb class="bottom-margin-40" />
      <h3 v-show="!validForm" class="fw-600 text-center">
        J'aimerais vous faire part de retours sur le site
      </h3>
    </header>
    <section v-show="!validForm" class="ContactFormSection">
      <div class="ContactFormContent">
        <span class="black02 fw-500 bottom-margin-8">Nom</span>
        <input
          v-model="userName"
          type="text"
          placeholder="Henri Martin"
          class="ContactFormInput"
        />
        <span class="black02 fw-500 bottom-margin-8">Adresse email</span>
        <input
          v-model="userMail"
          type="email"
          placeholder="henri.martin@monmail.fr"
          class="ContactFormInput"
        />
        <span class="black02 fw-500 bottom-margin-8"
          >À quel sujet souhaitez-vous nous contacter ?</span
        >
        <menu class="SelectorMenu">
          <div
            v-for="(item, index) in subjectsList"
            :key="index"
            class="SelectorItem"
            :class="[item === selectedSubject ? 'selected' : '']"
            @click="updateSelectedSubject(item)"
          >
            {{ item }}
          </div>
        </menu>
        <span class="black02 fw-500 bottom-margin-8">Message</span>
        <textarea
          v-model="userMessage"
          placeholder="Bonjour..."
          class="ContactFormTextarea"
        />
        <captcha-form
          :captcha-ref="captchaRef"
          @captchaUser="updateCaptchaUser"
        />
        <div v-if="alertMessage" class="ContactFormAlert">
          <span class="ContactFormAlertMessage">
            {{ alertMessage }}
          </span>
          <i
            class="v-icon mdi mdi-close-circle ContactFormAlertCloseIcon"
            @click="deleteAlertMessage"
          ></i>
        </div>
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
    subjectsList: ['Problème technique', 'Design', 'Autre'],
    emailConfig: '',
    alertMessage: null,
    validForm: false,
    disabledButton: false,
  }),
  mounted() {
    this.captchaRef = this.$generateCaptcha()
  },
  methods: {
    updateSelectedSubject(subject) {
      this.selectedSubject = subject
      // console.log(this.selectedSubject)
    },
    updateCaptchaUser(captcha) {
      this.captchaUser = captcha
    },
    validateForm() {
      if (this.captchaUser !== this.captchaRef) {
        this.alertMessage =
          "Le code de sécurité que vous avez renseigné n'est pas bon"
      }
      if (!this.userMessage) {
        this.alertMessage = 'Veuillez écrire un message'
      }
      if (!this.selectedSubject) {
        this.alertMessage = 'Veuillez choisir un sujet pour la demande'
      }
      if (!this.$checkEmail(this.userMail)) {
        this.alertMessage = 'Veuillez renseigner une adresse email valide'
      }
      if (!this.userMail) {
        this.alertMessage = 'Veuillez renseigner votre adresse email'
      }
      if (!this.userName) {
        this.alertMessage = 'Veuillez renseigner votre nom'
      }
      if (
        this.userName &&
        this.$checkEmail(this.userMail) &&
        this.selectedSubject &&
        this.userMessage &&
        this.captchaUser === this.captchaRef
      ) {
        // this.validForm = true
        this.disabledButton = true
        this.alertMessage = null
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
            // console.log(response)
            this.validForm = true
          })
          .catch((error) => {
            this.alertMessage = "L'envoi du mail a échoué..."
            this.disabledButton = false
            if (error.response) {
              console.log(error.response.data)
            }
          })
      }
    },
    deleteAlertMessage() {
      this.alertMessage = null
    },
  },
  head() {
    return {
      title: this.$getPageTitle(this.$route.path),
    }
  },
}
</script>

<style scoped>
div.container.container--fluid {
  padding-top: 68px;
}
</style>
