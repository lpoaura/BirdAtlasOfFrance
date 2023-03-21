export default {
  inserted: el => {
    function loadImage() {
      const imageElement = Array.from(el.children).find(
        el => el.className === "TopSectionPicture lazy"
      )
      if (imageElement) {
        // imageElement.addEventListener("load", () => {
        //   setTimeout(() => el.classList.add("loaded"), 100);
        // })
        imageElement.addEventListener("error", () => console.debug("error"))
        imageElement.classList.remove("lazy")
      }
    }

    function handleIntersect(entries, observer) {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          loadImage()
          observer.unobserve(el)
        }
      });
    }

    function createObserver() {
      const options = {
        root: null,
        threshold: "0"
      }
      const observer = new IntersectionObserver(handleIntersect, options)
      observer.observe(el)
    }

    if (window.IntersectionObserver) {
      createObserver()
    } else {
      loadImage()
    }
  }
};
