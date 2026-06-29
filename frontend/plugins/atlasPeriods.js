import { createAtlasPeriods } from '~/utils/atlasPeriods'

export default (_context, inject) => {
  inject('atlasPeriods', createAtlasPeriods())
}
