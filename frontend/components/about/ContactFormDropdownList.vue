<!-- AJOUTER v-model (revoir tout le js) -->
<template>
  <div
    v-click-outside="closeSelect"
    class="DropdownListWrapper"
    :style="{ 'z-index': zIndex }"
  >
    <div
      class="DropdownListSelectedOption"
      :class="[selectedItem ? '' : 'placeholder', selectIsOpen ? 'open' : '']"
      @click="openOrCloseSelect"
    >
      <span>{{ selectedItem || defaultMessage }}</span>
      <img
        class="DropdownListChevron"
        :src="selectIsOpen ? '/chevron-up.svg' : '/chevron-down.svg'"
      />
    </div>
    <div v-show="selectIsOpen" class="DropdownOptionsBox">
      <div class="DropdownOptionsOverflow">
        <li
          v-for="(item, index) in itemsList"
          :key="index"
          class="DropdownOption"
          @click="updateSelectedItem(item, index)"
        >
          {{ item }}
        </li>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    zIndex: {
      type: Number,
      required: true,
    },
    defaultMessage: {
      type: String,
      required: true,
    },
    itemsList: {
      type: Array,
      required: true,
    },
  },
  data: () => ({
    selectedItem: null,
    selectIsOpen: false,
  }),
  methods: {
    openOrCloseSelect() {
      this.selectIsOpen = !this.selectIsOpen
    },
    closeSelect() {
      this.selectIsOpen = false
    },
    updateSelectedItem(item, index) {
      this.$emit('selectedItem', [item, index])
      this.selectedItem = item
      this.selectIsOpen = false
    },
  },
}
</script>

<style scoped>
.DropdownListWrapper {
  width: 100%;
  height: 32px;
  margin-bottom: 24px;
}

.DropdownListSelectedOption {
  height: 32px;
  border: 1px solid rgba(38, 38, 38, 0.1);
  justify-content: space-between;
}

.DropdownListSelectedOption.open {
  border: 1px solid #eece25;
}

.DropdownListSelectedOption.placeholder {
  color: rgba(38, 38, 38, 0.6);
}

.DropdownOption {
  padding: 6px;
  font-size: 14px;
  line-height: 21px;
}

.DropdownOption:hover {
  background: rgba(238, 206, 37, 0.4);
  font-weight: bold;
}
</style>
