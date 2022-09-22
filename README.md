# Peanut Protocol

Send Crypto with just a <span class="italic">Link<span>. Non-custodial, zk-based tech.

<br>

## Instructions

(Assuming linux terminal. If on windows consider using [WSL](https://docs.microsoft.com/en-us/windows/wsl/install))

1. create local python installation, activate it, and install libraries

```
        python -m venv venv
        source venv/bin/activate [windows (with admin perms): .\venv\Scripts\Activate.ps1 ]
        pip install -r requirements.txt
```

2. go to app/ and install npm packages

```
        cd app/src
        npm install
```

<br>

That's it! Now you can run the server, or push to github (autodeploys to render).

<br>

### Useful commands:

(have to be run from within ```app/src/```)

```
npm run build-css
```

⬆️ This will run a script that builds all the tailwind css files once.⬆️ 

```
npm run build-css-forever
```

⬆️ Same thing, just does it continuosly whenever there's ANY change.


```
npm run start:dev
```

⬆️ This will run the server in development mode.⬆️ 

```
npm run start:prod
```

⬆️ This will run the server in production mode.⬆️ 

```
npm run yeet-it
```

⬆️ This says fuck it, builds the css, adds all files to a git commit, and pushes to github. It then gets autodeployed to www.mailcrypto.xyz.⬆️ 


## TODO

- [ ] erc20 support
- [ ] erc721/1155 support
- [ ] deploy to other EVM chains
- [ ] zk decentralized smart contract
- [ ] integration with notifications/billing
- [ ] security features (e.g. time locks, etc)
- [ ] 
