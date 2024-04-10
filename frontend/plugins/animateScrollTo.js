export default ({ app }, inject) => {
  const animateScrollTo = (scrollingElement, target, marginTop, duration) => {
    const start = scrollingElement.scrollTop
    const change = target - marginTop - start
    const startDate = +new Date()
    const easeInOutQuad = (t, b, c, d) => {
      // t => current time
      // b => start value
      // c => change in value
      // d => duration
      let t2 = t
      t2 /= d / 2
      if (t2 < 1) return (c / 2) * t2 * t2 + b
      t2 -= 1
      return (-c / 2) * (t2 * (t2 - 2) - 1) + b
    }
    const animateScroll = () => {
      const currentDate = +new Date()
      const currentTime = currentDate - startDate
      scrollingElement.scrollTop = parseInt(
        easeInOutQuad(currentTime, start, change, duration),
        10
      )
      if (currentTime < duration) {
        requestAnimationFrame(animateScroll)
      } else {
        scrollingElement.scrollTop = target - marginTop
      }
    }
    animateScroll()
  }
  // Inject $animateScrollTo(element, to, duration) in Vue, context and store.
  inject('animateScrollTo', animateScrollTo)
}
