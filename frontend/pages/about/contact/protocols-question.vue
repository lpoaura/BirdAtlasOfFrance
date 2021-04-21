<template>
  <v-container fluid>
    <header>
      <breadcrumb style="margin-bottom: 20px" />
      <h1 class="PageTitle">
        J'ai une question sur les méthodes de prospection
      </h1>
    </header>
    <section class="FormSection">
      <div class="FormContent">
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
          type="text"
          placeholder="henri.martin@monmail.fr"
        />
        <label for="selected-protocol">Méthode de prospection</label>
        <contact-select
          :z-index="5"
          default-message="EPOC, SHOC..."
          :items-list="protocolsList"
          @selectedItem="updateSelectedProtocol"
        />
        <label for="selected-protocol">Département</label>
        <contact-select
          :z-index="4"
          default-message="Département"
          :items-list="$departmentsList"
          @selectedItem="updateSelectedDepartment"
        />
        <label for="message">Message</label>
        <textarea id="message" v-model="userMessage" placeholder="Bonjour..." />
        <nuxt-link to="#" class="PrimaryButton">Envoyer</nuxt-link>
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
    selectedProtocol: null,
    selectedDepartment: null,
    userMessage: '',
    protocolsList: [
      'EPOC ODF',
      'EPOC',
      'STOC',
      'SHOC',
      'Observatoire Rapaces',
      'LIMAT',
      'Wetlands',
      'Listes complètes et données ponctuelles',
    ],
  }),
  methods: {
    updateSelectedProtocol(protocol) {
      this.selectedProtocol = protocol
      console.log(this.selectedProtocol)
    },
    updateSelectedDepartment(department) {
      this.selectedDepartment = department
      console.log(this.selectedDepartment)
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

.FormSection {
  display: flex;
}

.FormContent {
  margin: auto;
  display: flex;
  flex-direction: column;
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
</style>
