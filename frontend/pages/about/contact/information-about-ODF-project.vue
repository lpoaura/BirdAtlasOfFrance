<template>
  <v-container fluid>
    <header>
      <breadcrumb style="margin-bottom: 20px" />
      <h1 class="PageTitle">
        Je souhaite avoir des renseignements sur le projet ODF
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
        <label>Département</label>
        <contact-select
          :z-index="4"
          default-message="Département"
          :items-list="$departmentsList"
          @selectedItem="updateSelectedDepartment"
        />
        <label for="message">Message</label>
        <textarea id="message" v-model="userMessage" placeholder="Bonjour..." />
        <div class="PrimaryButton" @click="validateForm">Envoyer</div>
      </div>
    </section>
    <section v-show="validForm" class="ConfirmationSection">
      <div class="ConfirmationContent">
        <img class="ConfirmationPicture" src="/confirmation-of-receipt.svg" />
        <h1 class="ConfirmationTitle">Nous avons bien reçu votre demande</h1>
        <span class="ConfirmationSubtitle"
          >Nous mettons tout en œuvre pour vous répondre au plus vite !</span
        >
        <nuxt-link to="/" class="PrimaryButton"
          >Retour à la page d'accueil</nuxt-link
        >
      </div>
    </section>
  </v-container>
</template>

<script>
import Breadcrumb from '~/components/layouts/Breadcrumb.vue'
import ContactSelect from '~/components/about/ContactSelect.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
    'contact-select': ContactSelect,
  },
  data: () => ({
    userName: '',
    userMail: '',
    selectedDepartment: null,
    userMessage: '',
    alertMessage: null,
    validForm: false,
  }),
  methods: {
    updateSelectedDepartment(department) {
      this.selectedDepartment = department[0]
      // console.log(this.selectedDepartment)
    },
    validateForm() {
      if (!this.userMessage) {
        this.alertMessage = 'Veuillez écrire un message'
      }
      if (!this.selectedDepartment) {
        this.alertMessage = 'Veuillez sélectionner un département'
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
        this.selectedDepartment &&
        this.userMessage
      ) {
        this.validForm = true
        this.alertMessage = null
        const messageIntroduction = `Nom : ${this.userName} \nEmail : ${this.userMail} \nDépartement : ${this.selectedDepartment} \n\nMessage : \n`
        this.$axios.$post('http://127.0.0.1:3000/mail/send', {
          config: 'oiseauxdefrance',
          subject:
            '[Atlas ODF] Je souhaite avoir des renseignements sur le projet ODF',
          text: messageIntroduction + this.userMessage,
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
