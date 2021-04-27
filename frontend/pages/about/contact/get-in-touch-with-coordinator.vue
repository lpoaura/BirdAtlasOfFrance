<template>
  <v-container fluid>
    <header>
      <breadcrumb style="margin-bottom: 20px" />
      <h1 class="PageTitle">Je souhaite contacter un référent local</h1>
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
        <label>Qui souhaitez-vous contacter ?</label>
        <div class="CoordinatorsMenu">
          <div
            v-for="(item, index) in coordinatorsList"
            :key="index"
            class="CoordinatorsMenuItem"
            :class="[item === selectedCoordinator ? 'selected' : '']"
            @click="updateSelectedCoordinator(item)"
          >
            {{ item }}
          </div>
        </div>
        <label v-show="selectedCoordinator">Département</label>
        <contact-select
          v-show="selectedCoordinator"
          :z-index="4"
          default-message="Département"
          :items-list="$departmentsList"
          @selectedItem="updateSelectedDepartment"
        />
        <div
          v-show="selectedCoordinator === 'Mon référent local'"
          class="GridFeatureContent"
        >
          <v-switch
            v-model="gridFeatureIsKnow"
            inset
            dense
            color="#EECE25"
          ></v-switch>
          <label for="grid-feature" class="nomargin"
            >Je connais le numéro de la maille à prospecter</label
          >
          <input
            v-show="gridFeatureIsKnow"
            id="grid-feature"
            v-model="gridFeature"
            class="GridFeatureInput nomargin"
            type="text"
            placeholder="E080N638"
          />
        </div>
        <label v-show="selectedCoordinator" for="message">Message</label>
        <textarea
          v-show="selectedCoordinator"
          id="message"
          v-model="userMessage"
          placeholder="Bonjour..."
        />
        <captcha-form
          v-show="selectedCoordinator"
          :captcha-ref="captchaRef"
          @captchaUser="updateCaptchaUser"
        />
        <div
          v-show="selectedCoordinator"
          class="PrimaryButton"
          @click="validateForm"
        >
          Envoyer
        </div>
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
import CaptchaForm from '~/components/about/CaptchaForm.vue'

export default {
  components: {
    breadcrumb: Breadcrumb,
    'contact-select': ContactSelect,
    'captcha-form': CaptchaForm,
  },
  data: () => ({
    userName: '',
    userMail: '',
    selectedCoordinator: null,
    selectedDepartment: null,
    gridFeatureIsKnow: false,
    gridFeature: '',
    userMessage: '',
    captchaRef: '',
    captchaUser: '',
    coordinatorsList: ['Le coordinateur national', 'Mon référent local'],
    alertMessage: null,
    validForm: false,
  }),
  mounted() {
    this.captchaRef = this.$generateCaptcha()
  },
  methods: {
    updateSelectedCoordinator(coordinator) {
      this.selectedCoordinator = coordinator
      // console.log(this.selectedCoordinator)
    },
    updateSelectedDepartment(department) {
      this.selectedDepartment = department[0]
      // console.log(this.selectedDepartment)
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
      if (this.gridFeatureIsKnow && !this.gridFeature) {
        this.alertMessage =
          "Veuillez renseigner un numéro de maille, ou bien décocher l'option correspondante"
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
        (!this.gridFeatureIsKnow ||
          (this.gridFeatureIsKnow && this.gridFeature)) &&
        this.selectedDepartment &&
        this.userMessage &&
        this.captchaUser === this.captchaRef
      ) {
        this.validForm = true
        this.alertMessage = null
        let messageIntroduction = `Nom : ${this.userName} \nEmail : ${this.userMail} \nDépartement : ${this.selectedDepartment} \nSouhaite contacter : ${this.selectedCoordinator}`
        messageIntroduction += this.gridFeature
          ? `\nNuméro de maille : ${this.gridFeature} \n\nMessage : \n`
          : '\n\nMessage : \n'
        this.$mail.send({
          config: 'oiseauxdefrance',
          subject: '[Atlas ODF] Je souhaite contacter un référent local',
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

.nomargin {
  margin-bottom: 0;
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

.CoordinatorsMenu {
  margin-bottom: 16px;
  display: flex;
}

.CoordinatorsMenuItem {
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

.CoordinatorsMenuItem.selected {
  background: rgba(238, 206, 37, 0.2);
  border: 2px solid #eece25;
}

.GridFeatureContent {
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.GridFeatureInput {
  width: 140px;
  margin-left: 16px;
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
