import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mapConcert, mapVenue } from './ticketmaster.mjs';

const sampleTmVenue = {
  id: 'tm-venue-1',
  name: 'The Basement',
  address: { line1: '124 Main St' },
  city: { name: 'New Brunswick' },
  state: { stateCode: 'NJ' },
  country: { countryCode: 'US' },
  postalCode: '08901',
  location: { latitude: '40.4959', longitude: '-74.4470' },
  images: [{ url: 'https://example.com/venue.jpg' }],
};

test('mapVenue maps a fully-populated Ticketmaster venue', () => {
  const venue = mapVenue(sampleTmVenue);
  assert.equal(venue.id, 'tm-venue-1');
  assert.equal(venue.name, 'The Basement');
  assert.equal(venue.address, '124 Main St');
  assert.equal(venue.city, 'New Brunswick');
  assert.equal(venue.state, 'NJ');
  assert.equal(venue.country, 'US');
  assert.equal(venue.zipCode, '08901');
  // Ticketmaster returns lat/long as strings — must be parsed to numbers.
  assert.equal(venue.latitude, 40.4959);
  assert.equal(venue.longitude, -74.447);
  assert.equal(venue.imageURL, 'https://example.com/venue.jpg');
  assert.equal(venue.source, 'ticketmaster');
  assert.equal(venue.externalID, 'tm-venue-1');
});

test('mapVenue falls back when optional fields are missing', () => {
  const venue = mapVenue({ id: 'v2', name: 'Bare Venue' });
  assert.equal(venue.address, '');
  assert.equal(venue.city, '');
  assert.equal(venue.state, '');
  assert.equal(venue.country, 'USA');
  assert.equal(venue.zipCode, null);
  assert.equal(venue.imageURL, null);
  assert.ok(Number.isNaN(venue.latitude));
});

test('mapVenue prefers state.stateCode over state.name', () => {
  const venue = mapVenue({ id: 'v3', name: 'X', state: { name: 'New Jersey' } });
  assert.equal(venue.state, 'New Jersey');
});

const mappedVenue = mapVenue(sampleTmVenue);

test('mapConcert maps a fully-populated event', () => {
  const event = {
    id: 'evt-1',
    name: 'Midnight Runners Live',
    dates: { start: { dateTime: '2026-10-27T21:00:00Z' } },
    priceRanges: [{ min: 25, max: 40, currency: 'USD' }],
    images: [{ url: 'https://example.com/event.jpg' }],
    url: 'https://ticketmaster.com/event/evt-1',
    classifications: [{ genre: { name: 'Indie Rock' } }],
    _embedded: { attractions: [{ name: 'Midnight Runners' }] },
  };

  const concert = mapConcert(event, mappedVenue, { now: 1_000_000 });
  assert.equal(concert.id, 'evt-1');
  assert.equal(concert.artistName, 'Midnight Runners');
  assert.equal(concert.venueID, mappedVenue.id);
  assert.equal(concert.venueName, mappedVenue.name);
  assert.equal(concert.date, Date.parse('2026-10-27T21:00:00Z'));
  assert.equal(concert.minPrice, 25);
  assert.equal(concert.maxPrice, 40);
  assert.equal(concert.currency, 'USD');
  assert.equal(concert.genre, 'Indie Rock');
  assert.equal(concert.lastUpdated, 1_000_000);
});

test('mapConcert falls back to event.name when there is no attraction', () => {
  const event = { id: 'evt-2', name: 'Unnamed Showcase', dates: { start: { dateTime: '2026-11-01T00:00:00Z' } } };
  const concert = mapConcert(event, mappedVenue);
  assert.equal(concert.artistName, 'Unnamed Showcase');
});

test('mapConcert falls back to localDate when dateTime is absent', () => {
  const event = { id: 'evt-3', name: 'Matinee', dates: { start: { localDate: '2026-11-02' } } };
  const concert = mapConcert(event, mappedVenue);
  assert.equal(concert.date, Date.parse('2026-11-02'));
});

test('mapConcert returns null when the event has no usable date', () => {
  const event = { id: 'evt-4', name: 'TBD Show', dates: {} };
  assert.equal(mapConcert(event, mappedVenue), null);
});

test('mapConcert defaults currency to USD when no price range is given', () => {
  const event = { id: 'evt-5', name: 'Free Show', dates: { start: { dateTime: '2026-11-03T00:00:00Z' } } };
  const concert = mapConcert(event, mappedVenue);
  assert.equal(concert.currency, 'USD');
  assert.equal(concert.minPrice, null);
  assert.equal(concert.maxPrice, null);
});
