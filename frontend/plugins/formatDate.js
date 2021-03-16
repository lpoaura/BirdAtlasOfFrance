export default ({ app }, inject) => {
  const formatDate = (date) => {
    return new Date(date).toLocaleDateString('fr', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    })
  }
  // Inject $formatDate(date) in Vue, context and store.
  inject('formatDate', formatDate)
}
