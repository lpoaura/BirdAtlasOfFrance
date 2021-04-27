export default ({ app }, inject) => {
  const generateCaptcha = () => {
    const a = Math.floor(Math.random() * 10)
    const b = Math.floor(Math.random() * 10)
    const c = Math.floor(Math.random() * 10)
    const d = Math.floor(Math.random() * 10)
    const captcha = a.toString() + b.toString() + c.toString() + d.toString()
    return captcha
  }
  // Inject $generateCaptcha in Vue, context and store.
  inject('generateCaptcha', generateCaptcha)
}
