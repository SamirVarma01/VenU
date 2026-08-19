// Pure mapping functions from Ticketmaster Discovery API shapes to our
// Firestore Venue/Concert schema (mobile/src/types/models.ts). Extracted
// out of sync-concerts.mjs so they're unit-testable without hitting the
// network or Firestore.

export function mapVenue(tmVenue) {
  return {
    id: tmVenue.id,
    name: tmVenue.name,
    address: tmVenue.address?.line1 ?? '',
    city: tmVenue.city?.name ?? '',
    state: tmVenue.state?.stateCode ?? tmVenue.state?.name ?? '',
    country: tmVenue.country?.countryCode ?? 'USA',
    zipCode: tmVenue.postalCode ?? null,
    latitude: parseFloat(tmVenue.location?.latitude),
    longitude: parseFloat(tmVenue.location?.longitude),
    capacity: null,
    imageURL: tmVenue.images?.[0]?.url ?? null,
    source: 'ticketmaster',
    externalID: tmVenue.id,
  };
}

/**
 * Maps a Ticketmaster event + its already-mapped venue to a Concert.
 * Returns null when the event has no usable date, mirroring the skip
 * behavior in the original sync loop.
 */
export function mapConcert(tmEvent, venue, { now = Date.now() } = {}) {
  const dateTime = tmEvent.dates?.start?.dateTime
    ? Date.parse(tmEvent.dates.start.dateTime)
    : tmEvent.dates?.start?.localDate
      ? Date.parse(tmEvent.dates.start.localDate)
      : null;
  if (!dateTime) return null;

  const priceRange = tmEvent.priceRanges?.[0];
  const artistName = tmEvent._embedded?.attractions?.[0]?.name ?? tmEvent.name;

  return {
    id: tmEvent.id,
    name: tmEvent.name,
    artistName,
    venueID: venue.id,
    venueName: venue.name,
    date: dateTime,
    imageURL: tmEvent.images?.[0]?.url ?? null,
    ticketURL: tmEvent.url ?? null,
    minPrice: priceRange?.min ?? null,
    maxPrice: priceRange?.max ?? null,
    currency: priceRange?.currency ?? 'USD',
    genre: tmEvent.classifications?.[0]?.genre?.name ?? null,
    source: 'ticketmaster',
    externalID: tmEvent.id,
    lastUpdated: now,
  };
}
