<template>
  <div
    v-click-outside="closeSelect"
    class="DropdownListWrapper"
    :style="{ 'z-index': zIndex }"
  >
    <div class="DropdownListSelectedOption" @click="openOrCloseSelect">
      <h5 class="green01 fw-600 right-margin-8">
        {{ selectedItem }}
      </h5>
      <img
        class="DropdownListChevron"
        :src="
          selectIsOpen ? '/chevron-up-green.svg' : '/chevron-down-green.svg'
        "
      />
    </div>
    <div v-show="selectIsOpen" class="DropdownOptionsBox">
      <div class="DropdownOptionsOverflow">
        <li
          v-for="(item, index) in itemsList"
          :key="index"
          :value="item"
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
  model: {
    prop: 'selectedItem',
    event: 'change',
  },
  props: {
    zIndex: {
      type: Number,
      required: true,
    },
    selectedItem: {
      type: String,
      required: true,
    },
    itemsList: {
      type: Array,
      required: true,
    },
  },
  data: () => ({
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
      this.$emit('change', item)
      this.selectIsOpen = false
    },
  },
}
</script>

<style scoped>
.DropdownListWrapper {
  width: 100%;
  height: 42px;
  margin-bottom: 32px;
}

.DropdownListSelectedOption {
  height: 42px;
  border: 2px solid rgba(57, 118, 90, 0.1);
  justify-content: center;
}

.DropdownOption {
  padding: 6px;
  font-size: 12px;
  line-height: 18px;
}

.DropdownOption:hover {
  background: rgba(57, 118, 90, 0.1);
  font-weight: bold;
  color: #39765a;
}
</style>
