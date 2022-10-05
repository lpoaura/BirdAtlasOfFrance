export default ({ app }, inject) => {
  const detectMobile = () => {
    const toMatch = [
      /Android/i,
      /webOS/i,
      /iPhone/i,
      /iPad/i,
      /iPod/i,
      /BlackBerry/i,
      /Windows Phone/i,
    ]
    return toMatch.some((item) => {
      return navigator.userAgent.match(item)
    })
  }
  // Inject $detectMobile() in Vue, context and store.
  inject('detectMobile', detectMobile)
}