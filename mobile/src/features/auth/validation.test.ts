import { extractDomain, validateCollegeEmail } from './validation';

describe('validateCollegeEmail', () => {
  it('accepts .edu addresses', () => {
    expect(validateCollegeEmail('student@rutgers.edu')).toBe(true);
  });

  it('accepts .ac.uk and .ac.in addresses', () => {
    expect(validateCollegeEmail('student@oxford.ac.uk')).toBe(true);
    expect(validateCollegeEmail('student@iitb.ac.in')).toBe(true);
  });

  it('is case-insensitive', () => {
    expect(validateCollegeEmail('Student@Rutgers.EDU')).toBe(true);
  });

  it('rejects non-college domains', () => {
    expect(validateCollegeEmail('student@gmail.com')).toBe(false);
  });

  it('rejects domains that merely contain .edu, not end with it', () => {
    expect(validateCollegeEmail('student@edu.fake-scam.com')).toBe(false);
  });
});

describe('extractDomain', () => {
  it('returns the part after @, lowercased', () => {
    expect(extractDomain('Student@Scarletmail.Rutgers.EDU')).toBe('scarletmail.rutgers.edu');
  });

  it('returns an empty string when there is no @', () => {
    expect(extractDomain('not-an-email')).toBe('');
  });
});
