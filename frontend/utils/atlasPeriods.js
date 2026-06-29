export const ATLAS_ARCHIVE_END = '01/02/2024'
export const ATLAS_CURRENT_START = '2024'

const MONTH_NAMES = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
]

function parseArchiveEndDate() {
  const [day, month, year] = ATLAS_ARCHIVE_END.split('/')
  return {
    day: parseInt(day, 10),
    month: parseInt(month, 10),
    year: parseInt(year, 10),
  }
}

export function currentYear() {
  return new Date().getFullYear()
}

export function atlasCurrentPeriod() {
  return `${ATLAS_CURRENT_START} - ${currentYear()}`
}

export function atlasCurrentPeriodLong() {
  return `Atlas ${ATLAS_CURRENT_START}-${currentYear()}`
}

export function atlasArchiveBefore() {
  return `Avant ${ATLAS_CURRENT_START}`
}

export function atlasArchiveBeforeWithDate() {
  return `Avant le ${ATLAS_ARCHIVE_END}`
}

export function atlasCurrentAfter() {
  return `Après ${ATLAS_CURRENT_START}`
}

export function atlasPhenologyStartLabel() {
  const { day, month, year } = parseArchiveEndDate()
  const dayLabel = day === 1 ? '1er' : String(day)
  return `${dayLabel} ${MONTH_NAMES[month - 1]} ${year}`
}

export function speciesObservedInArchive() {
  return `Espèce observée avant ${ATLAS_CURRENT_START}`
}

export function speciesNotObservedInArchive() {
  return `Espèce non observée avant ${ATLAS_CURRENT_START}`
}

export function completenessIndexDescription() {
  return `Rapport entre le nombre d'espèces observées sur la période ${atlasCurrentPeriod()} et le nombre d'espèces observées sur les périodes précédentes.`
}

export function createAtlasPeriods() {
  return {
    ATLAS_ARCHIVE_END,
    ATLAS_CURRENT_START,
    currentYear,
    atlasCurrentPeriod,
    atlasCurrentPeriodLong,
    atlasArchiveBefore,
    atlasArchiveBeforeWithDate,
    atlasCurrentAfter,
    atlasPhenologyStartLabel,
    speciesObservedInArchive,
    speciesNotObservedInArchive,
    completenessIndexDescription,
  }
}
