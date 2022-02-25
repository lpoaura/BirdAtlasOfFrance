export default ({ app }, inject) => {
  const redLists = () => {
    return {
      "CR": {
        label: 'En danger critique',
        bgColor: 'rgb(211, 0, 27)',
        fontColor: '#fcfcfc',
      },
      "EN": {
        label: 'En danger',
        bgColor: 'rgb(251, 191, 0)',
        fontColor: '#000',
      },
      "VU": {
        label: 'Vulnérable',
        bgColor: 'rgb(255, 237, 0)',
        fontColor: '#000',
      },
      "NT": {
        label: 'Quasi menacée',
        bgColor: 'rgb(251, 242, 202)',
        fontColor: '#000',
      },
      "LC": {
        label: 'Préoccupation mineure',
        bgColor: 'rgb(120, 183, 74)',
        fontColor: '#fcfcfc',
      },
      "DD": {
        label: 'Données insuffisantes',
        bgColor: 'rgb(211, 212, 213)',
        fontColor: '#000',
      },
      "NA": {
        label: 'Non applicable',
        bgColor: 'rgb(145, 145, 145)',
        fontColor: '#fcfcfc',
      },
    }
  }
  // Inject $redLists() in Vue, context and store.
  inject('redLists', redLists)
}
