export default ({ app }, inject) => {
  const formatDate = (date, verbose) => {
    const THEdate = new Date(date)
    THEdate.setHours(0, 0, 0, 0)
    if (verbose) {
      const today = new Date()
      today.setDate(today.getDate())
      today.setHours(0, 0, 0, 0)
      const yesterday = new Date()
      yesterday.setDate(yesterday.getDate() - 1)
      yesterday.setHours(0, 0, 0, 0)
      if (
        THEdate.toLocaleDateString('fr', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
        }) ===
        today.toLocaleDateString('fr', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
        })
      ) {
        return "Aujourd'hui"
      }
      if (
        THEdate.toLocaleDateString('fr', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
        }) ===
        yesterday.toLocaleDateString('fr', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
        })
      ) {
        return 'Hier'
      } else {
        return THEdate.toLocaleDateString('fr', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
        })
      }
    } else {
      return THEdate.toLocaleDateString('fr', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      })
    }
  }
  // Inject $formatDate(date, verbose) in Vue, context and store.
  inject('formatDate', formatDate)
}
