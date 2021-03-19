export default ({ app }, inject) => {
  const websiteTreeView = [
    {
      title: 'Accueil',
      routerPath: '/',
    },
    {
      title: 'Carte de prospection',
      routerPath: '/prospecting',
    },
    {
      title: 'Participer',
      routerPath: '/get-involved',
    },
    {
      title: 'EPOC',
      routerPath: '/get-involved/epoc',
    },
    {
      title: 'STOC',
      routerPath: '/get-involved/stoc',
    },
    {
      title: 'STOM',
      routerPath: '/get-involved/stom',
    },
    {
      title: 'Observatoire Rapaces',
      routerPath: '/get-involved/observatoire-rapaces',
    },
    {
      title: 'LIMAT',
      routerPath: '/get-involved/limat',
    },
    {
      title: 'SHOC',
      routerPath: '/get-involved/shoc',
    },
    {
      title: 'Wetlands',
      routerPath: '/get-involved/wetlands',
    },
    {
      title: 'À propos',
      routerPath: '/about',
    },
    {
      title: 'Le projet ODF',
      routerPath: '/about/what-is-ODF-project',
    },
    {
      title: 'Contact',
      routerPath: '/about/contact',
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
