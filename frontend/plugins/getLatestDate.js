export default ({ app }, inject) => {
  const getLatestDate = (dates, verbose) => {
    return new Date(
      Math.max(...dates.map((item) => new Date(item)))
    ).toLocaleDateString('fr', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    })
  }
  // Inject $toPercent(decimal) in Vue, context and store.
  inject('getLatestDate', getLatestDate)
}
