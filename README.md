# summrise-canary — public build artifacts, no secrets

This repository serves two things and nothing else:

- **`SummriseSetup-<version>[-<port>].exe`** — the Windows installer for a canary build.
- **`summrise-device-<version>.exe` + `release-<version>.json`** — the app binary and the signed
  release document the device's updater consumes.

**The current build is `0.3.8`.** Everything older lives in `archive/` — kept so an incident can be
reproduced against the exact build that caused it, not as something to install.

## Installing

The installer is a normal Windows installer (NSIS/MUI2): it registers the service, adds an entry to
Add/Remove Programs, and can run silently.

```bat
:: interactive
SummriseSetup-0.3.8.exe

:: silent, into a chosen directory (the /D= must be last and unquoted)
SummriseSetup-0.3.8.exe /S /D=C:\SummriseInstall
```

Defaults: install `%ProgramFiles%\Summrise`, data `%ProgramData%\Summrise`, service `SummriseLaunch`.
The build in this repository serves **port 18090** so it can coexist with the pre-1.3 agent on 18080.

Verify:

```bat
curl http://127.0.0.1:18090/api/health
summrise-launch.exe --self-check C:\SummriseInstall --data C:\ProgramData\Summrise
```

Uninstall from Add/Remove Programs, or `uninstall.exe /S`; it removes the service and asks about the
data directory only when run interactively.

## The `-18090` / `-18080` suffixes

Builds published before 0.2.6 carried the port in the file name (the canary and the product listen on
different ports during the coexistence window). From 0.2.6 on, the port is a build input, not part of
the name; the 0.3.x files above are 18090.

## Updating a device from here

A device updates from the signed document, not from the installer:

```bat
:: point it at the document (once), then it checks on its own schedule
summrise-device.exe --set-update-source https://raw.githubusercontent.com/SilasVale/summrise-canary/main/release-0.3.8.json ^
    --channel canary --interval 21600 --allow-plaintext --data C:\ProgramData\Summrise
```

`--allow-plaintext` is only for a plain-http mirror on a trusted tunnel; the raw GitHub URL above is
https and does not need it. A device applies a release only after verifying the document's signature,
the artifact's SHA-256, the channel and the revocation list.

## Checksums

`SHA256SUMS` lists the current three artifacts. `certutil -hashfile <file> SHA256` on Windows, or
`sha256sum -c SHA256SUMS` where GNU coreutils exist.

## What is not here

No signing keys, no operator token, no grant key. The installer and the binaries embed only the
**public** halves; a build that cannot verify its own seed refuses to install, by design.

## Archive

`archive/` holds every earlier build this mirror published. The names carry the history: `-18080` and
`-18090` were the coexistence ports before the port became a build input, and `-ci-` marks the builds
the GitHub workflow produced before the local publish script existed. They are not maintained and not
advised for a new install.
