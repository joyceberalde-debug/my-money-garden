# 🌷 My Money Garden

A responsive personal finance tracker with Supabase Auth and a private, row-level-secured Postgres database.

## Features
- Sign up / sign in / sign out with email and password
- Income (Salary, Allowance, Bonus, etc.) and expenses
- Monthly budget limits with spending progress
- Savings goals and manual contributions
- Recurring monthly bills, due dates, paid/unpaid status
- Month picker, overview cards, responsive layout, Philippine peso formatting

## Free-tier setup
1. Create a Supabase project at https://supabase.com .
2. In **SQL Editor**, paste and run the full `schema.sql` file.
3. In **Authentication > Providers**, enable Email. Keep **Confirm email** enabled. For a personal account, consider disabling new public signups *after* creating your account. Turn on MFA in Supabase if supported for your configuration, and use a unique strong password.
4. In **Project Settings > API** (or **Connect**), copy the **Project URL** and the **publishable** (`sb_publishable_...`) or legacy **anon** key. **NEVER use the service_role/secret key.**
5. Edit `config.js` with those two public configuration values.
6. In **Authentication > URL Configuration**, set your Site URL to your deployed GitHub Pages URL. Add that same URL to Redirect URLs (for example `https://YOURUSERNAME.github.io/my-money-garden/`).
7. Create a **public** GitHub repository (for example `my-money-garden`), upload `index.html`, `config.js`, and optionally `README.md`. **Do not upload `schema.sql` if you prefer to keep database structure out of the repository** (it contains no credentials). In **Settings > Pages**, deploy from the main branch root. Your site will be at `https://YOURUSERNAME.github.io/my-money-garden/`.
8. Visit the site, create your account, verify your email, and sign in.

### Security essentials
- GitHub Pages is public static hosting. **Your page source and `config.js` are public**. This is expected for a Supabase publishable/anon key, but never publish a database password, secret, service-role key, or private financial records.
- Supabase Row Level Security policies in `schema.sql` isolate each signed-in user's records. Test with two separate accounts before relying on it.
- The app stores only manual financial entries. It does not connect to banks or move money.
- Free hosting and database quotas, uptime, backups, and availability can change. For valuable financial records, arrange periodic exports/backups from a trusted device; free tiers may not include automatic backups.
- This is a starter app, not a professionally security-audited financial product. It does not include password-reset UI, data export, or transaction editing. These are recommended follow-up improvements.
- Bills marked paid are not automatically added to expenses, to avoid double counting. Enter the expense separately.
- "Monthly net" is this month's income minus expenses, **not your actual bank balance**. Savings-goal totals are separately recorded values, not verified account balances.
- Recurring bill dates clamp to the last day of shorter months.

## Files
- `index.html`: complete mobile-friendly website
- `config.js`: Supabase public project configuration (edit before deployment)
- `schema.sql`: create tables, RLS, and ownership protections

## Test checklist
- Confirm login and logout
- Create income and expense entries and check monthly totals
- Add a budget and check spending progress
- Add a goal and increase saved amount
- Add a monthly bill and toggle paid/unpaid
- Log in with a second test account and verify that the first account's records are invisible
- Test on phone and desktop
