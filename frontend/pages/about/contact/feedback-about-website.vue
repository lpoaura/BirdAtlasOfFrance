<template>
  <v-container fluid>
    <header>
      <breadcrumb style="margin-bottom: 20px" />
      <h1 class="PageTitle">
        J'aimerais vous faire part de retours sur le site
      </h1>
    </header>
    <section v-show="!validForm" class="FormSection">
      <div class="FormContent">
        <div v-if="alertMessage" class="Alert">
          <span class="AlertMessage">
            {{ alertMessage }}
          </span>
          <i
            class="v-icon mdi mdi-close-circle AlertCloseIcon"
            @click="deleteAlertMessage"
          ></i>
        </div>
        <label for="user-name">Nom</label>
        <input
          id="user-name"
          v-model="userName"
          type="text"
          placeholder="Henri Martin"
        />
        <label for="user-mail">Adresse email</label>
        <input
          id="user-mail"
          v-model="userMail"
          type="email"
          placeholder="henri.martin@monmail.fr"
        />
        <label>À quel sujet souhaitez-vous nous contacter ?</label>
        <div class="SubjectsMenu">
          <div
            v-for="(item, index) in subjectsList"
            :key="index"
            class="SubjectsMenuItem"
            :class="[item === selectedSubject ? 'selected' : '']"
            @click="updateSelectedSubject(item)"
          >
            {{ item }}
          </div>
        </div>
        <label for="message">Message</label>
        <textarea id="message" v-model="userMessage" placeholder="Bonjour..." />
        <captcha-form
          :captcha-ref="captchaRef"
          @captchaUser="updateCaptchaUser"
        />
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

header {
  width: 100%;
  padding: 1.4% 16% 3% 16%;
  display: flex;
  flex-direction: column;
}

.PageTitle {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 32px;
  line-height: 48px;
  color: #000;
  text-align: center;
}

.FormSection,
.ConfirmationSection {
  padding-bottom: 2%;
  display: flex;
}

.FormContent {
  margin: auto;
  display: flex;
  flex-direction: column;
}

.Alert {
  width: 626px;
  height: 32px;
  padding: 0 2%;
  margin-bottom: 16px;
  border: 1px solid #f44336;
  box-sizing: border-box;
  border-radius: 8px;
  color: #f44336;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.AlertMessage {
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
}

.AlertCloseIcon {
  cursor: pointer;
}

label {
  margin-bottom: 8px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  color: #000;
}

input {
  width: 626px;
  height: 32px;
  margin-bottom: 16px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
  outline: none;
  padding-left: 2%;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: rgba(38, 38, 38, 0.6);
}

input:focus {
  border: 1px solid #39765a;
}

textarea {
  padding: 1.4% 2%;
  margin-bottom: 16px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
  outline: none;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: rgba(38, 38, 38, 0.6);
}

textarea:focus {
  border: 1px solid #39765a;
}

.SubjectsMenu {
  margin-bottom: 16px;
  display: flex;
}

.SubjectsMenuItem {
  padding: 8px 12px;
  margin-right: 10px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  box-sizing: border-box;
  border-radius: 8px;
  cursor: pointer;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  text-decoration: none;
  font-size: 12px;
  line-height: 18px;
  color: #000;
  white-space: nowrap;
}

.SubjectsMenuItem.selected {
  background: rgba(238, 206, 37, 0.2);
  border: 2px solid #eece25;
}

.ConfirmationContent {
  margin: auto;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.ConfirmationPicture {
  width: 280px;
  margin-bottom: 30px;
}

.ConfirmationTitle {
  margin-bottom: 16px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: 600;
  font-size: 24px;
  line-height: 36px;
  color: #262626;
}

.ConfirmationSubtitle {
  margin-bottom: 30px;
  font-family: 'Poppins', sans-serif;
  font-style: normal;
  font-weight: normal;
  font-size: 14px;
  line-height: 21px;
  color: #262626;
}
</style>
