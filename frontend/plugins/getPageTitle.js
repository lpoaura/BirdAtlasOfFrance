export default ({ app }, inject) => {
  const websiteTreeView = [
    {
      title: 'Accueil',
      route: '/',
    },
    {
      title: 'Home',
      route: '/en',
    },
    {
      title: 'Actualités',
      route: '/news',
    },
    {
      title: 'News',
      route: '/en/news',
    },
    {
      title: 'Carte de prospection',
      route: '/prospecting',
    },
    {
      title: 'Prospecting map',
      route: '/en/prospecting',
    },
    {
      title: 'Participer',
      route: '/get-involved',
    },
    {
      title: 'Get involved',
      route: '/en/get-involved',
    },
    {
      title: 'EPOC',
      route: '/get-involved/epoc',
    },
    {
      title: 'EPOC',
      route: '/en/get-involved/epoc',
    },
    {
      title: 'EPOC ODF',
      route: '/get-involved/epoc-odf',
    },
    {
      title: 'EPOC ODF',
      route: '/en/get-involved/epoc-odf',
    },
    {
      title: 'STOC',
      route: '/get-involved/stoc',
    },
    {
      title: 'STOC',
      route: '/en/get-involved/stoc',
    },
    {
      title: 'STOM',
      route: '/get-involved/stom',
    },
    {
      title: 'STOM',
      route: '/en/get-involved/stom',
    },
    {
      title: 'Observatoire Rapaces',
      route: '/get-involved/observatoire-rapaces',
    },
    {
      title: 'Observatoire Rapaces',
      route: '/en/get-involved/observatoire-rapaces',
    },
    {
      title: 'LIMAT',
      route: '/get-involved/limat',
    },
    {
      title: 'LIMAT',
      route: '/en/get-involved/limat',
    },
    {
      title: 'SHOC',
      route: '/get-involved/shoc',
    },
    {
      title: 'SHOC',
      route: '/en/get-involved/shoc',
    },
    {
      title: 'Wetlands',
      route: '/get-involved/wetlands',
    },
    {
      title: 'Wetlands',
      route: '/en/get-involved/wetlands',
    },
    {
      title: 'Prospections Atlas',
      route: '/get-involved/complete-lists',
    },
    {
      title: 'Prospections Atlas',
      route: '/en/get-involved/complete-lists',
    },
    {
      title: 'À propos',
      route: '/about',
    },
    {
      title: 'About',
      route: '/en/about',
    },
    {
      title: 'Le projet ODF',
      route: '/about/what-is-ODF-project',
    },
    {
      title: 'The ODF project',
      route: '/en/about/what-is-ODF-project',
    },
    {
      title: 'Contact',
      route: '/about/contact',
    },
    {
      title: 'Contact us',
      route: '/en/about/contact',
    },
    {
      title: "J'ai une question sur les méthodes de prospection",
      route: '/about/contact/question-about-protocols',
    },
    {
      title: 'I have a question about protocols',
      route: '/en/about/contact/question-about-protocols',
    },
    {
      title: 'Je souhaite avoir des renseignements sur le projet ODF',
      route: '/about/contact/information-about-ODF-project',
    },
    {
      title: 'I would like to get information about the ODF project',
      route: '/en/about/contact/information-about-ODF-project',
    },
    {
      title: 'Je souhaite contacter un référent local',
      route: '/about/contact/get-in-touch-with-coordinator',
    },
    {
      title: 'I would like to get in touch with a local coordinator',
      route: '/en/about/contact/get-in-touch-with-coordinator',
    },
    {
      title: "J'aimerais vous faire part de retours sur le site",
      route: '/about/contact/feedback-about-website',
    },
    {
      title: 'I would like to give you feedback about the website',
      route: '/en/about/contact/feedback-about-website',
    },
    {
      title: 'Autre demande',
      route: '/about/contact/other',
    },
    {
      title: 'Other request',
      route: '/en/about/contact/other',
    },
    {
      title: 'Lexique',
      route: '/about/glossary',
    },
    {
      title: 'Glossary',
      route: '/en/about/glossary',
    },
    {
      title: 'Mentions légales',
      route: '/about/legal-notices',
    },
    {
      title: 'Legal notices',
      route: '/en/about/legal-notices',
    },
    {
      title: 'Mobile',
      route: '/mobile',
    },
    {
      title: 'Mobile',
      route: '/en/mobile',
    },
  ]
  const getPageTitle = (route) => {
    const validRoute =
      route.endsWith('/') && route.length > 1 ? route.slice(0, -1) : route
    const pageItem = websiteTreeView.filter((item) => {
      return item.route === validRoute
    })
    return pageItem[0].title
  }
  inject('getPageTitle', getPageTitle)
}
