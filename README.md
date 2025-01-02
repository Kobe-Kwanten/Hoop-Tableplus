# hooptable
Small command line tool to start a tableplus session from hoop

## Showcase

The tool will prompt you to log in using `hoop login` behind the scenes.


```text
Logging in ...
Login succeeded
```

After you have logged in it will show the available conenctions:

```text
NAME                                COMMAND                                 TYPE       AGENT     STATUS   SECRETS   PLUGINS                                 
rdb-development       [ "psql" "-v" "ON_ERROR_STOP=1" ... ]   database   default   online   5         (5) access_control, audit, editor,...   
rdb-production        [ "psql" "-v" "ON_ERROR_STOP=1" ... ]   database   default   online   5         (6) access_control, audit, editor,...   
rdb-staging           [ "psql" "-v" "ON_ERROR_STOP=1" ... ]   database   default   online   5         (5) access_control, audit, editor,...   
rdb-test              [ "psql" "-v" "ON_ERROR_STOP=1" ... ]   database   default   online   5         (5) access_control, audit, editor,...   
```

Enter the name of the connection you want

```text
Enter the name of the connection: ${your input (e.g. rdb-development)
```

Next, it will show the available databases:

```text
Available databases:

  - template1
  - template0
  - postgres
  - development
  - staging
  - test
  - rdb
  - production
```

Enter the name of the database you want to open:

```shell
Enter the name of the database to connect to: ${your input (e.g. development)}
```

The tool will display your connection URL and it will open a tableplus window with the connection.


## Installing

Copy the script

```shell
sudo mkdir -p /usr/local/bin/hooptable
sudo cp script.sh /usr/local/bin/hooptable/script.sh
```

Add an alias to call the script

Open you config for zsh
```shell
code ~/.zshrc
```

Add the following to the config file:
```shell
alias hooptable="/bin/bash /usr/local/bin/hooptable/script.sh"
```

Restart your terminal or run:

```shell
source ~/.zshrc
```
