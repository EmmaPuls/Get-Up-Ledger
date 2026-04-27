<img width="80" height="80" alt="image" src="https://github.com/user-attachments/assets/cee7151c-6c47-433f-b18b-ecdf43a57981" /> 

### Get Up Ledger 
<img width="911" height="458" alt="Screenshot of the Get Up Ledger App showing three accounts and their current balances" src="https://github.com/user-attachments/assets/8f4f65f7-e9ad-4cb7-ae2b-6d92ea2cca2c" />

#### Requirements
- Up Bank account and API key
- MacOS 14.0+
- Xcode (to build it, will release it soon)

This app currently only works with Up Bank.

It is currently not released but you can download this repo and build the app yourself if you want to try it out.

I made this app because I wanted an easy way to export all of my data from Up Bank to a CSV file that I can fiddle around with.

Currently this only works with Up Bank (a neo bank backed by Bendigo Bank in Australia).

### How to use
- Open the app and select Settings
- Enter in your Up Bank API key 
  - You can generate your key with your Up mobile app, follow the directions on [Up's website](https://api.up.com.au/getting_started).
- Close the setting and click on "Accounts" in the sidebar

You should get a list of your accounts, you can now open your individual, 2Up & home loan accounts and view the transactsions. 

If you want to download the data for a particular account click the "Download All Transactions as a CSV".

**Note:** If you're account has a lot of transactions this action can take a while to fetch and download all the data. 

### Requests for changes
- Please open an [Issue on Github](https://github.com/EmmaPuls/Get-Up-Ledger/issues) to request new features or report bugs

### Follow-ups & known bugs
See [FOLLOWUPS.md](FOLLOWUPS.md) for the long-term roadmap, known bugs, and in-code TODOs (all tracked in [Jira](https://emmapuls.atlassian.net/browse/KAN)).

### Contributing

Releases are managed with [knope](https://knope.tech) and per-change changesets. Contributors should install knope locally so they can run `knope document-change` when a PR introduces a user-visible change.

```sh
brew install knope-dev/tap/knope
```

The pinned version is **0.22.4** (matching the `knope-dev/action@v2.1.2` step in `.github/workflows/release.yml`). Verify with `knope --version`.

When you make a change that should appear in `CHANGELOG.md`, run `knope document-change`, pick a severity (`patch` / `minor` / `major`), and commit the generated file in `.changeset/` alongside your code.
