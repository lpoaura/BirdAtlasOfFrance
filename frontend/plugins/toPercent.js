export default ({ app }, inject) => {
  const toPercent = (decimal) => {
    return Math.round(decimal * 100)
  }
  // Inject $toPercent(decimal) in Vue, context and store.
  inject('toPercent', toPercent)
}
