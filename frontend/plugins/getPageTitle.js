export default ({ app }, inject) => {
  const websiteTreeView = [
    {
      title: 'Accueil',
      routerPath: '/',
    },
    {
      title: 'Home',
      routerPath: '/en',
    },
    {
      title: 'Carte de prospection',
      routerPath: '/prospecting',
    },
    {
      title: 'Prospecting map',
      routerPath: '/en/prospecting',
    },
    {
      title: 'Participer',
      routerPath: '/get-involved',
    },
    {
      title: 'Get involved',
      routerPath: '/en/get-involved',
    },
    {
      title: 'EPOC',
      routerPath: '/get-involved/epoc',
    },
    {
      title: 'EPOC',
      routerPath: '/en/get-involved/epoc',
    },
    {
      title: 'EPOC ODF',
      routerPath: '/get-involved/epoc-odf',
    },
    {
      title: 'EPOC ODF',
      routerPath: '/en/get-involved/epoc-odf',
    },
    {
      title: 'STOC',
      routerPath: '/get-involved/stoc',
    },
    {
      title: 'STOC',
      routerPath: '/en/get-involved/stoc',
    },
    {
      title: 'STOM',
      routerPath: '/get-involved/stom',
    },
    {
      title: 'STOM',
      routerPath: '/en/get-involved/stom',
    },
    {
      title: 'Observatoire Rapaces',
      routerPath: '/get-involved/observatoire-rapaces',
    },
    {
      title: 'Observatoire Rapaces',
      routerPath: '/en/get-involved/observatoire-rapaces',
    },
    {
      title: 'LIMAT',
      routerPath: '/get-involved/limat',
    },
    {
      title: 'LIMAT',
      routerPath: '/en/get-involved/limat',
    },
    {
      title: 'SHOC',
      routerPath: '/get-involved/shoc',
    },
    {
      title: 'SHOC',
      routerPath: '/en/get-involved/shoc',
    },
    {
      title: 'Wetlands',
      routerPath: '/get-involved/wetlands',
    },
    {
      title: 'Wetlands',
      routerPath: '/en/get-involved/wetlands',
    },
    {
      title: 'Listes complètes et données ponctuelles',
      routerPath: '/get-involved/complete-lists',
    },
    {
      title: 'Listes complètes et données ponctuelles',
      routerPath: '/en/get-involved/complete-lists',
    },
    {
      title: 'À propos',
      routerPath: '/about',
    },
    {
      title: 'About',
      routerPath: '/en/about',
    },
    {
      title: 'Le projet ODF',
      routerPath: '/about/what-is-ODF-project',
    },
    {
      title: 'The ODF project',
      routerPath: '/en/about/what-is-ODF-project',
    },
    {
      title: 'Contact',
      routerPath: '/about/contact',
    },
    {
      title: 'Contact us',
      routerPath: '/en/about/contact',
    },
    {
      title: "J'ai une question sur les méthodes de prospection",
      routerPath: '/about/contact/protocols-question',
    },
    {
      title: 'I have a question about protocols',
      routerPath: '/en/about/contact/protocols-question',
    },
    {
      title: 'Mentions légales',
      routerPath: '/about/legal-notices',
    },
    {
      title: 'Legal notices',
      routerPath: '/en/about/legal-notices',
    },
    {
      title: 'Mobile',
      routerPath: '/mobile',
    },
    {
      title: 'Mobile',
      routerPath: '/en/mobile',
    },
  ]
  const getPageTitle = (route) => {
    const validRoute =
      route.endsWith('/') && route.length > 1 ? route.slice(0, -1) : route
    const pageItem = websiteTreeView.filter((item) => {
      return item.routerPath === validRoute
    })
    return pageItem[0].title
  }
  inject('getPageTitle', getPageTitle)
}
