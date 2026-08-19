// Pure functions with no Firebase dependency, kept separate from api.ts so
// they're testable without pulling in the live Firebase SDK (which Jest's
// default transform config can't parse — it's ESM and not in
// transformIgnorePatterns).

const COLLEGE_EMAIL_SUFFIXES = ['.edu', '.ac.uk', '.ac.in'];

export function validateCollegeEmail(email: string): boolean {
  const lower = email.toLowerCase();
  return COLLEGE_EMAIL_SUFFIXES.some((suffix) => lower.endsWith(suffix));
}

export function extractDomain(email: string): string {
  const parts = email.toLowerCase().split('@');
  return parts.length > 1 ? parts[1] : '';
}
