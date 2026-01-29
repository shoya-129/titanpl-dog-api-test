
import { titanpl } from 'eslint-plugin-titanpl';

export default [
  {
    ignores: ['**/*.d.ts', 'server/**', 'titan/**']
  },
  {
    files: ['app/actions/**/*.js'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        drift: 'readonly',
        t: 'readonly',
        req: 'readonly'
      }
    },
    rules: {
      'no-undef': 'off', // Ignore undef as we have custom globals
      'no-unused-vars': 'warn'
    }
  },
  titanpl
];